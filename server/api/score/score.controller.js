'use strict';

var _ = require('lodash');
var Score = require('./score.model');
var Gameresults = require('../gameresult/gameresult.model.js');
var ultimatescore = require('../../lib/ultimatescore.js');

// Get list of tournaments
exports.index = function(req, res) {
  Gameresults.find({tournament: req.params.tournament}, function (err, gameResults) {
    if(err) { return handleError(res, err); }
    if(!gameResults) { return res.json([]); }

    ultimatescore.computeScores(gameResults, gameResults, function(err, result) {
      return res.json(result);
    });

  });
};

// Get a single tournament
exports.timeseries = function(req, res) {
  return res.json({});
};

function handleError(res, err) {
  return res.send(500, err);
}
