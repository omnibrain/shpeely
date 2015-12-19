'use strict';

var _ = require('lodash');
var Player = require('./player.model');
var Tournament = require('../tournament/tournament.model.js');
var mongoose = require('mongoose');

// Get list of players
exports.index = function(req, res) {
  Player.find(function (err, players) {
    if(err) { return handleError(res, err); }
    return res.json(200, players);
  });
};

// Get a single player
exports.show = function(req, res) {
  Player.findById(req.params.id, function (err, player) {
    if(err) { return handleError(res, err); }
    if(!player) { return res.send(404); }
    return res.json(player);
  });
};

// Creates a new player in the DB.
exports.create = function(req, res) {
  Player.create(req.body, function(err, player) {
    if(err) { return handleError(res, err); }
    return res.json(201, player);
  });
};

// disconnects a player from a user
exports.disconnect = function(req, res) {

  if(!req.body.player) {
      return res.json(400, {msg: 'player id missing'});
  }

  Player.findById(req.body.player, function (err, player) {
    if(typeof player._user == 'undefined') {
      return res.json(400, {msg: 'Player ' + player._id + ' is not connected to a user'});
    }

    if(req.user._id != req.body.player) {
      // User requesting disconnection is not connected to that player!
      // Check if the player requesting the disconnection is an admin. 

      // find the tournament containing the player to disconnect
      Tournament
        .findOne({
          members: mongoose.Types.ObjectId(req.body.player)
        })
        .populate('members')
        .exec(function(err, tournament) {

          var deletingPlayer = _.find(tournament.members, function(member) {
            return member._user == req.user.id;
          });

          if(deletingPlayer.role != 'admin') {
            return res.json(403, {msg: 'Trying to disconnect other users from their players? Now that\s not nice...'});
          } else {
            // all good!
            player._user = undefined;
            player.save(function(err, player) {
              return res.json(200, player);
            });
          }
      });


    } else {
      // all good! Remove reference from player
      player._user = undefined;
      player.save( function(err, player) {
        return res.json(200, player);
      });
    }

  });
};


// Updates an existing player in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Player.findById(req.params.id, function (err, player) {
    if (err) { return handleError(res, err); }
    if(!player) { return res.send(404); }
    var updated = _.merge(player, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, player);
    });
  });
};

// Deletes a player from the DB.
exports.destroy = function(req, res) {
  Player.findById(req.params.id, function (err, player) {
    if(err) { return handleError(res, err); }
    if(!player) { return res.send(404); }
    player.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
