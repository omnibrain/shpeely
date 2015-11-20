'use strict';

var _ = require('lodash');
var Tournament = require('./tournament.model');
var User = require('../user/user.model.js');
var Player = require('../player/player.model.js');
var mongoose = require('mongoose');

// Get list of tournaments
exports.index = function(req, res) {
  Tournament.find(function (err, tournaments) {
    if(err) { return handleError(res, err); }
    return res.json(200, tournaments);
  });
};

// Get a single tournament
exports.show = function(req, res) {
  Tournament.findById(req.params.id, function (err, tournament) {
    if(err) { return handleError(res, err); }
    if(!tournament) { return res.send(404); }
    return res.json(tournament);
  });
};

// Creates a new tournament in the DB.
exports.create = function(req, res) {

  var creatorId = mongoose.Types.ObjectId(req.body.creator);

  User.findById(creatorId, function(err, user) {
    if(err) {return handleError(err)}

    // create new player of the user that created the tournament
    var player = {
      name: user.name,
      role: 'admin',
      _user: user,
    };

    Player.create(player, function(err, player) {
      if(err) {return handleError(err)}

      var tournament = {
        name: req.body.name,
        members: [player],
      }

      Tournament.create(tournament, function(err, tournament) {
        if(err) { return handleError(res, err); }

        return res.json(201, tournament);
      });
    });
  });
};

// Updates an existing tournament in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Tournament.findById(req.params.id, function (err, tournament) {
    if (err) { return handleError(res, err); }
    if(!tournament) { return res.send(404); }
    var updated = _.merge(tournament, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, tournament);
    });
  });
};

// Deletes a tournament from the DB.
exports.destroy = function(req, res) {
  Tournament.findById(req.params.id, function (err, tournament) {
    if(err) { return handleError(res, err); }
    if(!tournament) { return res.send(404); }
    tournament.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  console.error(err);
  return res.send(500, err);
}
