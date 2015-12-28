'use strict';

var compose = require('composable-middleware');
var _ = require('lodash');
var User = require('../user/user.model.js');
var Player = require('../player/player.model.js');
var Tournament = require('../tournament/tournament.model.js');
var Gameresult = require('../gameresult/gameresult.model.js');

var auth = require('../../auth/auth.service.js');


/**
 * Checks if the user role meets the minimum requirements of the route
 */
function hasPlayerRole(roleRequired) {
  if (!roleRequired) throw new Error('Required player role needs to be set');

  return compose()
    .use(auth.isAuthenticated())
    .use(function meetsRequirements(req, res, next) {

      // check if user is allowed to delete game results
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
              role: roleRequired
            }, function(err, player) {

              if(!player) {
                res.json(403, {err: 'Only admins are allowed to delete game results'})
              } else {
                next();
              }
            });
          });
        });
      });
    });
}

exports.hasPlayerRole = hasPlayerRole
