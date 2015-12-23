'use strict';

var _ = require('lodash');
var mongoose = require('mongoose');
var async = require('async');
var Message = require('./message.model');
var Player = require('../player/player.model.js');
var Tournament = require('../tournament/tournament.model.js');


// send a claim player request to the admins of a tournament
exports.claimPlayer = function(req, res) {
  var player = req.body.player;
  var sender = req.user._id;

  // find the tournament of this player
  Tournament
    .findOne({members: mongoose.Types.ObjectId(req.body.player)})
    .populate('members')
    .exec(function(err, tournament) {
      
      // send the request to all admins
      var admins = _.chain(tournament.members)
        .filter(function(member) {
          return member.role == 'admin' 
        })
        .map(function(member) {
          return member._user; 
        })
        .value();

      async.each(admins, function(admin, callback) {

        // load the player
        Player.findById(player, function(err, player) {

          if(err) { return handleError(res, err); }
          if(!player) {return res.json(400, {err: 'Player does not exist'}); }

          var message = Message({
            sender: req.user._id,
            recipient: admin,
            type: 'claim-player-request',
            data: {
              tournament: tournament,
              player: player
            }
          });
          message.save(callback);
        });

      }, function(err) {
        if(err) { return handleError(res, err); }
        return res.json(200, {'msg': 'ok'});
      });
    });
}

// Get list of messages
exports.index = function(req, res) {
  Message
    .find({recipient: req.user._id})
    .lean()
    .limit(100)
    .sort('-time')
    .populate('sender')
    .exec(function (err, messages) {
      if(err) { return handleError(res, err); }

      // remove sensitive data from sender field
      _.each(messages, function(msg) {
        msg.sender = _.pick(msg.sender, ['_id', 'name', 'email']);
      });
      return res.json(200, messages);
    });
};

exports.count = function(req, res) {
  Message
    .find({recipient: req.user._id, read: false})
    .exec(function (err, messages) {
      if(err) { return handleError(res, err); }
      return res.json(200, {unread: messages.length});
    });
};


// Get a single message
exports.show = function(req, res) {
  Message.findById(req.params.id, function (err, message) {
    if(err) { return handleError(res, err); }
    if(!message) { return res.send(404); }
    return res.json(message);
  });
};

// Creates a new message in the DB.
exports.create = function(req, res) {
  Message.create(req.body, function(err, message) {
    if(err) { return handleError(res, err); }
    return res.json(201, message);
  });
};

// Updates an existing message in the DB.
exports.update = function(req, res) {

  // whitelist of fields to allow updating
  var update = _.pick(req.body, ['read'])

  if(req.body._id) { delete req.body._id; }
  Message.findById(req.params.id, function (err, message) {
    if (err) { return handleError(res, err); }
    if(!message) { return res.send(404); }
    var updated = _.merge(message, update);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, message);
    });
  });
};

// Deletes a message from the DB.
exports.destroy = function(req, res) {
  Message.findById(req.params.id, function (err, message) {
    if(err) { return handleError(res, err); }
    if(!message) { return res.send(404); }
    message.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
