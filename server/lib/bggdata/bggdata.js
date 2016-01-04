var _ = require('lodash');

var os = require('os');
var config = require('../../config/environment');
var BggDataModel = require('./bggdata.model.js');

// Cache for responses from BGG
var TTL = 3600 * 24 * 3 // cache for 7 days
var CachemanMongo = require('cacheman-mongo');
var cache = new CachemanMongo(config.mongo.uri, {
  collection: 'bggdata'
});

// BGG API
var bgg = require('bgg')({
  timeout: 600e3,
  retry: {
    initial: 100,
    multiplier: 2,
    max: 15e3,
  }
});

// Simple wrapper for BGG api
var BGGData = function () {};


function toObject(item, callback) {
  if(typeof item === 'undefined') {
      return callback(new Error('BGG item is undefined'));
  }
  if(typeof item === 'string') {
    try {
      callback(null, JSON.parse(item));
    } catch (e) {
      callback(e);
    }
  } else {
    callback(null, item);
  }
}

BGGData.prototype.cache = cache;

BGGData.prototype.startCacheUpdate = function() {

  var self = this;

  var fetchInterval = Math.round(60 * 1000 * os.cpus().length * (Math.random() + 1)); // 120-60s

  var fetchData = function() {
    // get the cached data that is the next to expire
    BggDataModel.find({key: {$regex: '^info:'}}).sort('expire').limit(1).exec(function(err, bggdata) {
      if(bggdata.length) {
        var bggid = bggdata[0].key.split(':')[1];
        self.loadInfo(bggid, function(err, res) {
          if(err) {console.error(err)}
        });
      }
      setTimeout(fetchData, fetchInterval);
    });
  };

  setTimeout(fetchData, fetchInterval);
}

BGGData.prototype.search = function (query, cb) {

  var cacheKey = 'search:' + query;

  // check cache first
  cache.get(cacheKey, function(err, val) {
    if(err) throw err; 
    
    if(val) {
      return cb(null, val);
    } else {
      // try exact query first
      bgg('search', {query:query, exact:1, type: 'boardgame'}).then(function(res){

          if(res.items.total > 0) {
            var items = res.items.total == 1 ? [res.items.item] : res.items.item;

            escapeKeys(items);
            cache.set(cacheKey, items, TTL, function(err, res) {
              toObject(res, cb);
            });
          } else {
            // try the fuzzy search
            bgg('search', {query:query, type: 'boardgame'}).then(function(res){
                var items = (res.items.total != 0) ? res.items.item : [];
                escapeKeys(items);
                cache.set(cacheKey, items, TTL, function(err, res) {
                  toObject(res, cb);
                });
            });
          }
          
      }, function(error) {
        console.error('BoardgameGeek API timeout')
        cb(new Error('BoardgameGeek API timeout'));
      });
    }
  });

};

var getCacheKey = function(bggid) {
  return 'info:' + bggid;
}

BGGData.prototype.loadInfo = function (bggid, cb) {
  //load from BBG
  bgg('thing', {id:bggid, stats:true}).then(function(data){
      if(!data) {
        // no data returned...
        cb(new Error("No data found on BGG for id " + bggid));
      } else {
        if(typeof data.items.item === 'string') {
          // this is a bug of BGG
          try {
            data.items.item = JSON.parse(data.items.item);
          } catch (e) {
            cb(e);
          }
        }
        // everything as expected
        escapeKeys(data.items.item);
        cache.set(getCacheKey(bggid), data.items.item, TTL, function(err, res) {
          if(err) { return cb(err)}
          toObject(res, cb);
        });
      }
    }, function(err) {
      console.error('BoardgameGeek API timeout')
      cb(new Error('BoardgameGeek API timeout'));
    });
};

BGGData.prototype.info = function (bggid, cb) {

  var self = this;

	if(!bggid) { return cb(new Error('bggid is not defined')) }

  cache.get(getCacheKey(bggid), function(err, val) {

    // found in cache
    if(val && typeof val === 'object') {
      return cb(null, val);
    }

    self.loadInfo(bggid, cb);

  });
};

BGGData.prototype.shortInfo = function (bggid, cb) {
  this.info(bggid, function(err, info) {
    if(err) {return cb(err)}

    var shortInfo = {
      id: bggid,
      name: _.find([].concat(info.name), function(name) { return name.type == 'primary'; }).value,
    }

    cb(null, shortInfo);
  });
}

// escape $ and & in keys
function escapeKeys(obj) {
    if (!(Boolean(obj) && typeof obj == 'object'
      && Object.keys(obj).length > 0)) {
        return false;
    }
    Object.keys(obj).forEach(function(key) {
        if (typeof(obj[key]) == 'object') {
            escapeKeys(obj[key]);
        } else {
            if (key.indexOf('.') !== -1) {
                var newkey = key.replace(/\./g, '_dot_');
                obj[newkey] = obj[key];
                delete obj[key];
            }
            if (key.indexOf('$') !== -1) {
                var newkey = key.replace(/\$/g, '_amp_');
                obj[newkey] = obj[key];
                delete obj[key];
            }

        }
    });
    return true;
}

console.log('start bggdata updates...');
var bggdata = new BGGData();
bggdata.startCacheUpdate();

module.exports = bggdata;
