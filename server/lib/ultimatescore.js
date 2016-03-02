var async = require('async');
var _ = require('lodash');
var stdev = require('compute-stdev');
var util = require('util');
var config = require('../config/environment');

// Cache for the computed scores
var TTL = 3600 * 24 * 3 // cache for 7 days
var CachemanMongo = require('cacheman-mongo');

// Simple wrapper for BGG api
var cache = new CachemanMongo(config.mongo.uri, {
  collection: 'gamestats',
  ttl: TTL,
});

var bggdata = require('./bggdata/bggdata.js');

var UltimateScore = function () {};

UltimateScore.prototype.cache = cache;

UltimateScore.prototype.timeSeries = function (allResults, cb) {
	var self = this;

  // gather meta data of the results
  var meta = _.chain(allResults)
    .sortBy('time')
    .map(function(result) {
      return {
        time: result.time.getTime(),
        gameresult: result._id,
      };
    })
    .value();

	// sort the results by time
	allResults = _.sortBy(allResults, function (result) {
		return result.time;
	});

	// compute the ultimate scores in chromological order
	var allGamesChronological = [];
	for(var i = 0; i < allResults.length; i++) {
		allGamesChronological.push(_.first(allResults, i+1));
	}

	async.map(allGamesChronological, function (games, cb) {
		self.computeScores(games, games, function (err, scores) {
      if(err) { return cb(err)}

			// add time and gameresult id to the scores
			scores.push({
        time: _.last(games).time,
        gameresult: _.last(games),
      });
			cb(null, scores);
		})
	}, function (err, results) {
    if(err) { return cb(err)}

		// get the names of all players
		var players = {};
		_.chain(results)
			.last()
			.map(function (result) { return result.player; })
			.compact()
			.each( function (player) {
				players[player] = [];
			});

		// add the data to the players
		var index = 1;
		_.each(results, function (scores) {

			var time = _.find(scores, function (score) {
				return score.time;	
			}).time;
			var gameresult = _.find(scores, function (score) {
				return score.gameresult;	
			}).gameresult;

			_.each(scores, function (score) {
				if(score.player) {
					var tick = {
						y: score.score,
						x: index,
						//time: time.getTime(),
            //gameresult: gameresult._id,
					};
					players[score.player].push(tick);
				}
			});
			index += 1;
		});
		
		// put the data in highcharts conform format
		var series = _.map(players, function (data, player) {
			return {
				player: player,
				data: data,
			};
		});

		cb(null, {series: series, meta: meta});
	});
};


UltimateScore.prototype.computeScores = function (gameResults, allResults, cb) {

  // try to load from cache
  var key = _.chain(allResults.concat(gameResults))
      .map(function(gameResult) {
        return gameResult._id + '_' + gameResult.lastEdit.getTime();
      })
      .sort()
      .flatten()
      .value()
      .join(':');

  cache.get(key, function(err, value) {

    if(err) {return cb(err); }
    if(value) {
      cb(null, value)
    } else {

      async.waterfall([
          function(cb){
            // get bggstats for the games
            var bggids = _.chain(gameResults).pluck('bggid').union().value();
            async.map(bggids, bggdata.info, cb);
          },
          function (bggstats, cb) {
              
            bggstats = _.groupBy(bggstats, function(stat) {
              return stat.id; 
            });

            // add the bgg stats to the game results
            gameResults = _.map(gameResults, function (gameResult, i) {
              gameResult.weight = bggstats[gameResult.bggid][0].statistics.ratings.averageweight.value;
              return gameResult;
            });

            // Filter the games in question from all games
            var games = _.pluck(gameResults, 'bggid');
            var relevantGames = _.filter(allResults, function (gameResult) {
              return _.contains(games, gameResult.bggid);
            });

            // group all games by num players and game
            var sameGames = _.groupBy(relevantGames, function (gameResult) {
              return sameGameKey(gameResult.scores.length, gameResult.bggid);
            });

            // add the scores of all games to the game results
            gameResults = _.map(gameResults, function (gameResult) {
              var games = sameGames[sameGameKey(gameResult.scores.length, gameResult.bggid)];

              var allScores = _.reduce(games, function (memo, gameResult) {
                var scores = _.pluck(gameResult.scores, 'score');
                return memo.concat(scores);
              }, []);

              gameResult.allScores = allScores;

              return gameResult;
            });


            // add sd and avg to the game results
            gameResults = _.map(gameResults, function(gameResult) {
              gameResult.avg = _.reduce(gameResult.allScores, function(memo, score) { return memo + score}, 0) / gameResult.allScores.length;
              gameResult.std = stdev(gameResult.allScores);
              return gameResult;
            });

            // add ultimate scores to the player's scores
            gameResults = _.map(gameResults, function (gameResult) {

              gameResult.scores = _.map(gameResult.scores, function (score) {
                score.ultimateScore = computeScore(score.score, gameResult.avg, gameResult.std, gameResult.weight);
                return score;
              });

              return gameResult;
            });

            // extract the player scores and merge them
            var playerScores = _.chain(gameResults)
              .pluck('scores')
              .flatten()
              .value();
            
            var scores = _.reduce(playerScores, function (memo, score) {
                var player = score.player;
                memo[player] = memo[player] || 0;
                memo[player] += score.ultimateScore;
                return memo;
              }, {});

            // create array of key/value (player/score) objects instead of a single object
            // multiply them by 100 (arbitrary factor to make scores more readable) and sort
            scores = _.chain(scores)
              .map(function(score, player){
                return {player: player, score: Math.round(score * 100) };
              })
              .sortBy(function(playerScore) { return -playerScore.score; })
              .value();

            cb(null, scores);
          },
      ], function(err, scores) {

        if(err) return cb(err);
        cache.set(key, scores, function(err) {
          if(err) {return cb(err)}
          return cb(null, scores);
        });
      });

    }
    
  });

};

function computeScore(score, mean, sd, weight) {

	var weightFactor = 3;
	var result = ((score - mean) / sd) * weight * weightFactor;
  //console.log('////////////////////');
  //console.log('score: ', score);
  //console.log('mean: ', mean);
  //console.log('weight: ', weight);
  //console.log('sd: ', sd);
  //console.log('result:', result);
  return result
}

function sameGameKey(numPlayers, bggid) {
  return numPlayers + 'players_' + bggid;
}

module.exports = new UltimateScore();
