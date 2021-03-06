'use strict';

var _ = require('lodash');
var Score = require('./score.model');
var Gameresults = require('../gameresult/gameresult.model.js');
var Player = require('../player/player.model.js');
var ultimatescore = require('../../lib/ultimatescore.js');
var async = require('async');

// Get current scores of the players
exports.index = function(req, res) {

  Gameresults.find({tournament: req.params.tournament}, function (err, gameResults) {

    if(err) { return handleError(res, err); }
    if(!gameResults) { return res.json([]); }

    ultimatescore.computeScores(gameResults, gameResults, function(err, scores) {
      populatePlayers(scores, function(err, scores) {
        if(err) return handleError(res, err);
        return res.json(scores);
      });
    });
  });
};

// Get time series of the score
exports.timeseries = function(req, res) {
  Gameresults.find({tournament: req.params.tournament}, function (err, gameResults) {
    if(err) { return handleError(res, err); }
    if(!gameResults) { return res.json([]); }

    ultimatescore.timeSeries(gameResults, function(err, scores) {

      // populate players
      async.map(scores.series, function(score, callback) {

        Player.findById(score.player, function(err, player) {
          if(err) return callback(err);
          return callback(null, {name: player.name, data: score.data});
        });

      }, function(err, seriesPopulated) {
        if(err) return handleError(res, err);
        scores.series = seriesPopulated;
        return res.json(scores);
      });
    });
  });
};

exports.gameresult = function(req, res) {

  // find the game result
  Gameresults.findById(req.params.gameresult, function (err, gameResult) {
    if(err) { return handleError(res, err); }
    if(!gameResult) { return res.json([]); }

    // get all gameresults of this tournament
    Gameresults.find({tournament: gameResult.tournament}, function (err, allResults) {

      // compute the score
      ultimatescore.computeScores([gameResult], allResults, function(err, scores) {

        // populate players
        populatePlayers(scores, function(err, scores) {
          if(err) return handleError(res, err);
          return res.json(scores);
        });
      });
    });
  });
};

// populate players
function populatePlayers(scores, callback) {
  async.map(scores, function(score, callback) {

    Player.findById(score.player, function(err, player) {
      if(err) return callback(err);
      return callback(null, {score: score.score, player: player});
    });

  }, function(err, scoresPopulated) {
    callback(err, scoresPopulated);
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
