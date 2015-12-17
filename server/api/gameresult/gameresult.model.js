'use strict';

// TODO: Refactor: Move all non model related logic out of this class...

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var Player = require('../player/player.model.js');
var Tournament = require('../tournament/tournament.model.js');
var bggdata = require('../../lib/bggdata.js');
var async = require('async');
var _ = require('lodash')

// cache for computations
var config = require('../../config/environment');
var TTL = 3600 * 24 * 7 // cache for 7 days
var CachemanMongo = require('cacheman-mongo');
var cache = new CachemanMongo(config.mongo.uri, {
  collection: 'stats'
});


var GameresultSchema = new Schema({
  bggid: {type: Number, required: true},
  tournament: {type : mongoose.Schema.ObjectId, ref : 'Tournament', required: true},
  time: {type: Date, default: Date.now},
  lastEdit: {type: Date, default: Date.now},
  scores: [{
    score: Number,
    player: {type : mongoose.Schema.ObjectId, ref : 'Player'}
  }]
});

// Hooks

// update lastEdit of the tournament
GameresultSchema.post('save', function(gameresult) {
  Tournament.update({_id: gameresult.tournament}, {lastEdit: gameresult.time}, {}, function(err, res) {
    // nothing to do?
  });
});


// Virtual Methods
GameresultSchema.virtual('winner').get(function(){
	return _.max(this.scores, function(player){
		return player.score;
	});
});

GameresultSchema.virtual('loser').get(function(){
	return _.min(this.scores, function(player){
		return player.score;
	});
});


GameresultSchema.statics.players = function(query, cb) {

	this.find(query, function(err, games){
		if(err) { return cb(err); }
		var playerIds = _.chain(games)
			.pluck('scores')
			.flatten()
			.pluck('player')
      .map(function(item){return String(item)})
			.union()
			.value();

    // populate players
    async.map(playerIds, function(playerId, callback) {
      Player.findById(playerId, callback);
    }, function(err, players) {
      cb(err, players);
    });
    
	});

};

GameresultSchema.statics.games = function(query, cb) {

	this.find(query, function(err, games){
		if(err) { return cb(err); }

		var bggids = _.chain(games)
			.pluck('bggid')
			.union()
			.value();

    async.map(bggids, bggdata.info, function(err, bgginfo) {
      cb(null, bgginfo);
    });

	});
};

GameresultSchema.statics.scores = function(query, cb) {
	var pipeline = [
		{ $match: query },
		{ $unwind: '$scores' },
		{ $project: { score:'$scores.score' }}
	];
	this.aggregate(pipeline, function (err, scores) {
		var scores = _.map(scores, function(score) { return score.score; });
		return cb(null, scores);
	});
};


GameresultSchema.statics.gamePlayerStats = function(player, cb) {

  var pipeline = []

	pipeline.push({
    $project: // add numPlayers to the results for grouping
			{ bggid:'$bggid',
				numPlayers: { $size:'$scores' },
				scores:'$scores' }
		});

  pipeline.push({$unwind:'$scores' });

  pipeline.push({
    // group by game and num players and compute stats
			$group: {
				_id: {
					bggid:'$bggid', numPlayers:'$numPlayers', player:'$scores.player'
				},
				player: {$first: '$scores.player'},
				game: {$first: '$bggid'},
				players: {$first: '$numPlayers'},
				average:{$avg:'$scores.score'},
				highscore:{$max:'$scores.score'},
				lowscore:{$min:'$scores.score'},
				games:{$sum:1} 
			}
		});

  pipeline.push({ $sort: { games: -1 } });

  // TODO: Filter first to reduce data size!
  if(player) {
    pipeline.push({
      $match: {
        'player': mongoose.Types.ObjectId(player)
      }
    });
  }

	this.aggregate(pipeline, function(err, gamePlayerStats){
		if(err) { cb(err); return; }

    console.log(gamePlayerStats[0]);

    async.map(gamePlayerStats, function(stats, callback) {
      // remove id and populate players
      delete stats._id; 

      Player.findById(stats.player, function(err, player) {
        stats.player = player;
        callback(null, stats);
      });

    }, function(err, gamePlayerStats) {
      async.map(gamePlayerStats, function(stats, callback) {
        bggdata.shortInfo(stats.game, function(err, shortInfo) {
          stats.game = shortInfo;
          callback(null, stats);
        });
      }, function(err, gamePlayerStats) {
        cb(null, gamePlayerStats);
      });
    });

	});
};


GameresultSchema.statics.playerStats = function(query, cb) {

	var playerStats = {};

	this
    .find(query)
    .populate('scores.player')
    .exec(function(err, games){
		if(err) cb(err);

		// get winners and losers of all games
		var winners = _.chain(games)
			.map(function(game){
				return game.winner.player;
			})
      .value();

		var losers = _.chain(games)
			.map(function(game){
				return game.loser.player;
			})
      .value();

		// calculate number of games played
		var players = _.chain(games)
			.pluck('scores')
			.flatten()
      //.tap( function(item) {
        //console.log(item);
        //return item;
      //})
			.pluck('player')
			.value();

		//initialize stats object with all players
		getPlayers(games).forEach(function(player) {
			playerStats[player._id] = {
				//default values
				games: 0,
				wins: 0,
				losses: 0,
        player: player
			};
		});

		//count victories and losses
		winners.forEach(function(winner){
			playerStats[winner._id].wins++;
		});
		losers.forEach(function(loser){
			playerStats[loser._id].losses++;
		});
		//count plays
		players.forEach(function(player){
			playerStats[player._id].games++;
		});

		//object to array
		var stats = _.chain(playerStats)
			.map(function(value, key) {
				return _.extend({player:key}, value);
			})
			.value();

		// calculate win and lose ratio
		stats.forEach(function(stat){
			stat.winRatio = stat.wins / stat.games;
			stat.loseRatio = stat.losses / stat.games;
		});

		//sort the result
		stats = _.sortBy(stats, function(stat){
			return -stat.games;
		});

		cb(null, stats);

	});
}

function computeGameStats(games, callback) {

  //compute highscores, lowscores, averages
  var stats = _.chain(games)
    .map(function(game){

      var minMaxTotal = _.reduce(game.scores, function(memo, player){
        // compute min, max and total of this game
        memo.min = _.min([memo.min, player], function(player) { return player.score });
        memo.max = _.max([memo.max, player], function(player) { return player.score });
        memo.total += player.score;
        return memo;
      }, {
        min: {score: Infinity},
        max: {score: -Infinity},
        total: 0,
      });

      return {
        game: game.bggid,
        players: _.pluck(game.scores, 'player'),
        totalScore: minMaxTotal.total,
        min: minMaxTotal.min,
        max: minMaxTotal.max,
        winner: minMaxTotal.max.name,
      };
    })
    .groupBy(function(item){
      return sameGameKey(item.game, item.players.length);
    })
    .map(function(games, key){

      // KPIs
      var numPlayers = games[0].players.length
      var totalScore = _.reduce(games, function(memo, game) { return memo + game.totalScore; }, 0);
      var lowscore = _.min(games, function(game) { return game.min.score; }).min.toObject();
      var highscore = _.max(games, function(game) { return game.max.score; }).max.toObject();

      // games per player
      var gamesPerPlayer = _.reduce(games, function(memo, game) {
        _.each(game.players, function(player){
          if(!(player in memo)) memo[player] = 0;
          memo[player]++;
        });
        return memo;
      }, {});

      // winners
      var wins = _.reduce(games, function(memo, game) {
        var winner = game.max.player;
        if(!(winner in memo)) memo[winner] = 0;
        memo[winner]++;
        return memo;
      }, {});

      // win ratios per player and highest win ratio
      var winRatios = _.reduce(gamesPerPlayer, function(memo, numGames, player) {
        var winsPerPlayer = wins[player] || 0;
        memo[player] = winsPerPlayer / gamesPerPlayer[player];	
        return memo;
      }, {});

      var playerWithHighestWinRatio = _.chain(winRatios)
        .pairs()
        .max(function(pair){return pair[1]})
        .value()[0];

      // best player
      var mostWins = _.chain(wins)
        .pairs()
        .max(function(pair){return pair[1]})
        .value()[0];

      return {
        highscore: highscore,
        lowscore: lowscore,
        players: numPlayers,
        totalGames: games.length,
        game: games[0].game,
        averageScore: totalScore / (games.length * numPlayers),
        wins: wins,
        gamesPerPlayer: gamesPerPlayer,
        winRatios: winRatios,
        playerWithHighestWinRatio : playerWithHighestWinRatio,
        mostWins: mostWins,
      };
    })
    .sortBy(function(stat){
      return -stat.totalGames;
    })
    .value();

    // populate players
    async.map(stats, function(stat, callback) {

      //populate 
      populatePlayerKeys(stat.winRatios, function(err, winRatios) {
        if(err) return callback(err);
        stat.winRatios = winRatios; 
        populatePlayerKeys(stat.wins, function(err, wins) {
          stat.wins = wins;
          populatePlayerKeys(stat.gamesPerPlayer, function(err, gamesPerPlayer) {
            stat.gamesPerPlayer = gamesPerPlayer;

            // populate the remaining fields
            var players = [
              stat.highscore.player,
              stat.lowscore.player,
              stat.playerWithHighestWinRatio,
              stat.mostWins,
            ];

            async.map(players, function(playerId, callback) {
              Player.findById(playerId).lean().exec(callback);
            }, function(err, players) {

              stat.highscore.player = players[0];
              stat.lowscore.player = players[1];
              stat.playerWithHighestWinRatio = players[2];
              stat.mostWins = players[3];

              // finally populate the game
              bggdata.shortInfo(stat.game, function(err, bgginfo) {
                stat.game = bgginfo;
                callback(null, stat);
              });
            });
          });
        });

      });
               
    }, function(err, res) {
      callback(null, res);
    });
 
}

function getCacheKey(query, gameresults) {
  var lastEdit = gameresults.length ? _.max(gameresults, 'lastEdit').lastEdit.getTime() : '';
  return 'gameStats:' + (JSON.stringify(query) + lastEdit).replace(/[^a-zA-Z0-9]/g, '');
};


GameresultSchema.statics.gameStats = function(query, cb) {

	this.find(query, function(err, games){
    if(err) {return cb(err)}

    var cacheKey = getCacheKey(query, games);

    //cache.del(cacheKey, function() {});

    cache.get(cacheKey, function(err, val) {
      if(err) { return cb(err)}

      if(val) {
        // found in cache
        return cb(null, JSON.parse(val));
      } else {
        // not found in cache
        computeGameStats(games, function(err, result) {
          cache.set(cacheKey, JSON.stringify(result), TTL, function(err, res) {
            cb(err, result);
          });
        });
      }
    });

	});
}

// helpers
function populatePlayerKeys(obj, callback) {

  async.map(_.pairs(obj), function(pair, callback) {

    Player.findById(pair[0], function(err, player) {
      if(err) return callback(err);
      callback(null, {
        player: player,
        value: pair[1],
      });
    });

  }, function(err, res) {
    callback(err, res);
  });
}

function getPlayers(games) {
	return _.chain(games)
			.pluck('scores')
			.flatten()
			.pluck('player')
			.union()
			.value();
}

function getGames(games) {
	return _.chain(games)
		.map(function(game){
			return game.game;
		})
		.union()
		.value();
}

function sameGameKey(bggid, numPlayers) {
  return numPlayers + 'players_' + bggid;
}

module.exports = mongoose.model('Gameresult', GameresultSchema);







