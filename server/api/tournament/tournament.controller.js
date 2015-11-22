'use strict';

var _ = require('lodash');
var Tournament = require('./tournament.model');
var User = require('../user/user.model.js');
var Player = require('../player/player.model.js');
var Gameresults = require('../gameresult/gameresult.model.js');
var mongoose = require('mongoose');

// find tournament by slug or id and polulate
// the players
function findTournament(id, callback) {
  Tournament.findOne({slug: id}, function (err, tournament) {
    if(err) { return callback(err); }

    if(tournament) {
      // found by slug
      tournament.populate('members', function(err, tournament) {
        callback(null, tournament);
      });

    } else {
      // now try to find by id
      Tournament.findById(req.params.id, function (err, tournament) {
        if(err) { return callback(err); }
        if(!tournament) {return callback(null, tournament)}

        tournament.populate('members', function(err, tournament) {
          return callback(null, tournament);
        });
      });
    }
  });
}

// Get list of tournaments
exports.index = function(req, res) {
  Tournament.find(function (err, tournaments) {
    if(err) { return handleError(res, err); }
    return res.json(200, tournaments);
  });
};

// Get a single tournament
exports.show = function(req, res) {

  findTournament(req.params.id, function(err, tournament) {
    if(err) { return handleError(res, err); }
    if(!tournament) { return res.send(404); }
    return res.json(tournament);
  });

};

// Returns tournaments of the logged in user. Optional with a query
exports.mine = function(req, res) {

  // find players of this user
  Player.find({'_user': req.user._id}, function(err, players) {

    var query = _.merge(req.query, {
      members: {
        '$elemMatch': {'$in': _.pluck(players, '_id')}
        }
    });
    
    // find all tournaments of all players of this user
    Tournament.find(query)
      .populate('members')
      .exec(function(err, tournaments) {
        if(!tournaments) {return res.send(404)}
        res.send(tournaments);
    });
    
  });

  
}

// Creates a new tournament in the DB.
exports.create = function(req, res) {

  // create new player of the user that created the tournament
  var player = {
    name: req.user.name,
    role: 'admin',
    _user: req.user,
  };

  Player.create(player, function(err, player) {
    if(err) {return handleError(err)}

    console.log('Created player: ', player);

    var tournament = {
      name: req.body.name,
      members: [player],
    }

    Tournament.create(tournament, function(err, tournament) {
      if(err) { return handleError(res, err); }

      // populate the member
      tournament.populate('members', function(err, tournament) {
        console.log('Created tournament: ', tournament);
        return res.json(201, tournament);
      });
    });
  });
};



// UNFINISHED....
exports.gameresults = function(req, res) {
  findTournament(req.params.id, function(err, tournament) {
    if(err) { return handleError(res, err); }
    if(!tournament) { return res.send(404); }

    var query = _.defaults({tournament: tournament._id});
    Gameresults
      .find(query) 
      .sort('time', -1)
      .limit(req.query.limit || 3000) // limit to 3000 by default
      .exec(function(err, res) {
           
      });
    
  });
};
exports.games = function(req, res) {
  // TODO
  res.json({});
};
exports.players = function(req, res) {
  // TODO
  res.json({});
};




function handleError(res, err) {
  console.error(err);
  return res.send(500, err);
}
