var bgg = require('bgg');
var _ = require('lodash');

// Cache for responses from BGG
var TTL = 3600 * 24 * 3 // cache BGG responses for 3 days
var Cacheman = require('cacheman');

// Simple wrapper for BGG api
var BGGData = function () {};

var cache = new Cacheman({ttl: TTL})

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
            cache.set(cacheKey, items, cb);
          } else {
            // try the fuzzy search
            bgg('search', {query:query, type: 'boardgame'}).then(function(res){
                var items = (res.items.total != 0) ? res.items.item : [];
                cache.set(cacheKey, items, cb);
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
    if(val) { return cb(null, val)}

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
					// everything as expected
          cache.set(cacheKey, data.items.item, cb)
				}
			});

  });

};


module.exports = new BGGData();
