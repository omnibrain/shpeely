var bgg = require('bgg');
var _ = require('lodash');

// Cache for responses from BGG
var TTL = 3600 * 24 * 3 // cache BGG responses for 3 days
var Cacheman = require('cacheman');

// Simple wrapper for BGG api
var BGGData = function () {};

var cache = new Cacheman({
  ttl: TTL,
  engine: 'redis',
});

function toObject(item, callback) {
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

            cache.set(cacheKey, items, function(err, res) {
              toObject(res, cb);
            });
          } else {
            // try the fuzzy search
            bgg('search', {query:query, type: 'boardgame'}).then(function(res){
                var items = (res.items.total != 0) ? res.items.item : [];
                cache.set(cacheKey, items, function(err, res) {
                  toObject(res, cb);
                });
            });
          }
          
      });
    }
  });

};

BGGData.prototype.info = function (bggid, cb) {
	if(!bggid) { return cb(new Error('bggid is not defined')) }

  var cacheKey = 'info:' + bggid;

  cache.get(cacheKey, function(err, val) {

    // found in cache
    if(val && typeof val === 'object') {
      return cb(null, val);
    }

		//load from BBG
		bgg('thing', {id:bggid, stats:true}).then(function(data){
				if(!data) {
					// no data returned...
					cb(new Error("No data found on BGG for id " + bggid));
				} else if (data.html) {
					// error returned by BGG
					var error = 'BGG responded ' + data.html.head.title;
					console.log(error);
					cb(new Error(error));
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
          cache.set(cacheKey, data.items.item, function(err, res) {
            toObject(res, cb);
          });
				}
			});

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

module.exports = new BGGData();
