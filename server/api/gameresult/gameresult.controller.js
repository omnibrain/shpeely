'use strict';

var _ = require('lodash');
var Gameresult = require('./gameresult.model');
var Tournament = require('../tournament/tournament.model.js');
var Player = require('../player/player.model.js');

var async = require('async');
var _ = require('lodash');

// Get list of gameresults
exports.index = function(req, res) {
  Gameresult.find(function (err, gameresults) {
    if(err) { return handleError(res, err); }
    return res.json(200, gameresults);
  });
};

// Get a single gameresult
exports.show = function(req, res) {
  Gameresult.findById(req.params.id, function (err, gameresult) {
    if(err) { return handleError(res, err); }
    if(!gameresult) { return res.send(404); }
    return res.json(gameresult);
  });
};

// Creates a new gameresult in the DB.
exports.create = function(req, res) {

  async.map(req.body.scores, function(score, callback) {
    Player.findById(score.player, function(err, player) {

      // create new player objects for players that 
      // don't exists yet
      if(!player) {

        // create new player
        Player.create({
          name: score.player,
        }, function(err, player) {

          // add the id of the newly created player
          score.player = player._id;

          // add new player to the tournament
          Tournament.update({_id: req.body.tournament}, {
            '$push': {
              'members': player._id,
            }
          }, function(err, nrUpdated) {
            callback(null, score);
          });

        });

      } else {
        // player already exists...
        callback(null, score);
      }

    });
  }, function(err, scores) {
    if(err) { return handleError(res, err); }

    var gameresult = req.body;
    gameresult.scores = scores;

    Gameresult.create(gameresult, function(err, gameresult) {
      if(err) { return handleError(res, err); }
      return res.json(201, gameresult);
    });
  });

};

// Updates an existing gameresult in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Gameresult.findById(req.params.id, function (err, gameresult) {
    if (err) { return handleError(res, err); }
    if(!gameresult) { return res.send(404); }
    var updated = _.merge(gameresult, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, gameresult);
    });
  });
};

// Deletes a gameresult from the DB.
exports.destroy = function(req, res) {
  Gameresult.findById(req.params.id, function (err, gameresult) {
    if(err) { return handleError(res, err); }
    if(!gameresult) { return res.send(404); }
    gameresult.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
