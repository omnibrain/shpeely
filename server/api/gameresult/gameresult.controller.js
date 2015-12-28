'use strict';

var _ = require('lodash');
var Gameresult = require('./gameresult.model');
var Tournament = require('../tournament/tournament.model.js');
var Player = require('../player/player.model.js');

var async = require('async');
var _ = require('lodash');
var bggdata = require('../../lib/bggdata.js')

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
    // populate players
    gameresult.populate('scores.player', function(err, gameresult) {
      //add game name
      bggdata.shortInfo(gameresult.bggid, function(err, bgginfo) {
        if(err) { return handleError(res, err); }
        gameresult = gameresult.toObject()
        gameresult.game = bgginfo;
        return res.json(gameresult);
      });
    });
  });
};

// Creates a new gameresult in the DB.
exports.create = function(req, res) {

  console.log('request', req.body);
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

    console.log('scores', scores);
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

  // check if user is allowed to delete game results
  var userId = req.user._id;
  Player.find({_user: req.user._id}, function(err, players) {
    if(err) { return handleError(err); }
    if(!players) {return res.json(404, {err: 'No player found with user id ' + req.user._id}); }

    // get the game result
    Gameresult.findById(req.params.id, function (err, gameresult) {
      if(err) { return handleError(res, err); }
      if(!gameresult) { return res.send(404); }

      // get the tournament
      Tournament.findById(gameresult.tournament, function(err, tournament) {
        if(err) { return handleError(res, err); }
        if(!tournament) { return res.send(404, {err: 'No tournament found with id ' + gameresult.tournament}); }

        var memberIds = _.map(tournament.members, function(id) {
          return id.toHexString();
        });
        var playerIds = _.map(_.pluck(players, '_id'), function(id) {
          return id.toHexString();
        });

        var playerId = _.intersection(memberIds, playerIds);

        Player.findOne({
          _id: playerId,
          role: 'admin'
        }, function(err, player) {

          if(!player) {
            res.json(403, {err: 'Only admins are allowed to delete game results'})
          } else {
            gameresult.remove(function(err) {
              if(err) { return handleError(res, err); }
              return res.send(204);
            });
          }
        });
      });
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
