var async = require('async');
var _ = require('lodash');
var stdev = require('compute-stdev');
var util = require('util');

var bggdata = require('./bggdata.js');

var UltimateScore = function () {};

UltimateScore.prototype.timeSeries = function (allResults, cb) {
	var self = this;

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
			// add time to the scores
			var time = _.last(games).time;
			scores.push({time:time});
			cb(null, scores);
		})
	}, function (err, results) {

		// get the names of all players
		var players = {};
		_.chain(results)
			.last()
			.map(function (result) { return result.player; })
			.compact()
			.each( function (player) {
				players[player] = [];
			})

		// add the data to the players
		var index = 1;
		_.each(results, function (scores) {
			var time = _.find(scores, function (score) {
				return score.time;	
			}).time;

			_.each(scores, function (score) {
				if(score.player) {
					var tick = {
						y: score.score,
						x: index,
						time: time.getTime(),
					};
					players[score.player].push(tick);
				}
			});
			index += 1;
		});
		
		// put the data in highcharts conform format
		var series = _.map(players, function (data, player) {
			return {
				name: player,
				data: data,
			};
		});

		cb(null, series);
	});
};


UltimateScore.prototype.computeScores = function (gameResults, allResults, cb) {

	async.waterfall([
			function(cb){
				// get bggstats for the games
				var bggids = _.pluck(gameResults, 'bggid');
				async.map(bggids, bggdata.info, cb);
			},
			function (bggstats, cb) {
				// add the bgg stats to the game results
				gameResults = _.map(gameResults, function (gameResult, i) {

          if(!bggstats[i].statistics && typeof bggstats[i] === 'string') {
            // for some reason, the data returned by BGG is a string 
            // instead of an object
            bggstats[i] = JSON.parse(bggstats[i]);
            console.log(bggstats[i].statistics.ratings);
          }

					gameResult.weight = bggstats[i].statistics.ratings.averageweight.value;
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
		return cb(null, scores);
	});

	return null;
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
