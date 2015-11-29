'use strict';

var _ = require('lodash');
var Tournament = require('./tournament.model');
var User = require('../user/user.model.js');
var Player = require('../player/player.model.js');
var Gameresults = require('../gameresult/gameresult.model.js');
var mongoose = require('mongoose');
var async = require('async');

var bggdata = require('../../lib/bggdata.js');

// find tournament by slug or id and polulate
// the players
function findTournament(id, callback) {

  Tournament.findOne({_id:id}, function (err, tournament) {

    if(err) {

      if(err.name =='CastError') {
        // id seems to be a slug, not an id
        // now try to find by slug
        Tournament.findOne({slug: id}, function (err, tournament) {
          if(err) { return callback(err); }
          if(!tournament) { return callback(null, null); }

          tournament.populate('members', function(err, tournament) {
            return callback(null, tournament);
          });
        });
      } else {
        return callback(err);
      }

    } else {
      if(!tournament) { return res.send(404); }
      tournament.populate('members', function(err, tournament) {
        callback(null, tournament);
      });
    }

  });
}

// Get list of tournaments
exports.index = function(req, res) {
  Tournament.find(req.query, function (err, tournaments) {
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


exports.gameresults = function(req, res) {
  findTournament(req.params.id, function(err, tournament) {
    if(err) { return handleError(res, err); }
    if(!tournament) { return res.send(404); }

    var query = _.defaults({tournament: tournament._id});
    Gameresults
      .find(query) 
      .sort({'time': -1})
      .limit(req.query.limit || 1000) // limit to 3000 by default
      .populate('scores.player')
      .exec(function(err, gameResults) {
        if(err) { return handleError(res, err); }
        
        // add game info
        async.map(_.pluck(gameResults, 'bggid'), bggdata.shortInfo.bind(bggdata), function(err, shortInfos) {

          // add the short info to the game results
          _.each(shortInfos, function(shortInfo, i) {
            gameResults[i] = gameResults[i].toObject();
            gameResults[i].game = shortInfo;
          });

          res.json(gameResults)
        });
      });
  });
};

exports.games = function(req, res) {

  var query = _.extend({ tournament: req.params.id }, req.query);

  if(req.query.numPlayers) {
    query.scores = {
      $size: req.query.numPlayers,
    }
    delete query.numPlayers
  }

  Gameresults.gameStats(query, function(err, gameStats) {
    res.json(gameStats.length == 1 ? gameStats[0] : gameStats);
  });
};
exports.players = function(req, res) {
  // TODO
  res.json({});
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
