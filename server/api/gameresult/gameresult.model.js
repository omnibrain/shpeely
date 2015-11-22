'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var Player = require('../player/player.model.js');
var bggdata = require('../../lib/bggdata.js');
var async = require('async');
var _ = require('lodash')

var GameresultSchema = new Schema({
  bggid: {type: Number, required: true},
  tournament: {type : mongoose.Schema.ObjectId, ref : 'Tournament', required: true},
  time: {type: Date, default: Date.now},
  scores: [{
    score: Number,
    player: {type : mongoose.Schema.ObjectId, ref : 'Player'}
  }]
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


GameresultSchema.statics.gamePlayerStats = function(query, player, cb) {

	var pipeline = [
		{$project: // add numPlayers to the results for grouping
			{ bggid:'$bggid',
				numPlayers: { $size:'$scores' },
				scores:'$scores' }
		},{
			$unwind:'$scores'
		},{ // group by game and num players and compute stats
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
		},{
			$sort: {
				games: -1
			}
		}
	];

	if(player) {
		pipeline.push({
			$match: {
				'_id.player':player
			}
		});
	}

	this.aggregate(pipeline, function(err, gamePlayerStats){
		if(err) { cb(err); return; }
		cb(null, gamePlayerStats);
	});
};

module.exports = mongoose.model('Gameresult', GameresultSchema);
