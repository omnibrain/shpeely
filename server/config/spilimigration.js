/**
 * Populates the DB with the game results of the old spili webiste.
 */

'use strict';

var Tournament = require('../api/tournament/tournament.model.js');
var Player = require('../api/player/player.model.js');
var Gameresult = require('../api/gameresult/gameresult.model.js');
var User = require('../api/user/user.model');
var _ = require('lodash');
var async = require('async');

// connect to the spili database
var MongoClient = require('mongodb').MongoClient;

MongoClient.connect("mongodb://localhost:27017/spili", function(err, db) {
  if(err) {
    console.error('Failed to connect to the Spili Database');
    return;
  } else {

    // find user
    setTimeout(function() {
      User.findOne({email: 'r.voellmy@gmail.com'}, function(err, user) {

        if(err) {console.error(err); return}

        // create player
        Player.create({
          name: 'Raphael',
          role: 'admin',
          _user: user._id
        }, function(err, player) {

          // create tournament
          Tournament.create({
            name: 'Spililove 2015',
            members: [player._id],
            created: new Date('2015/1/1')
          }, function(err, tournament) {

            // add the game results of the spili database
            var coll = db.collection('gameresults')
            coll.find().toArray(function(err, gameresults) {

              // create dict of players and add default player
              var players = {}
              players[player.name] = player;

              async.eachSeries(gameresults, function(result, callback) {

                // create players if they don't exists yet
                async.eachSeries(result.players, function(player, callback) {

                  if(!players[player.name]) {
                    Player.create({name: player.name}, function(err, newPlayer) {
                      if(err) {return callback(err)}

                      players[player.name] = newPlayer;

                      // add player to the tournament
                      tournament.members.push(newPlayer);
                      tournament.save();

                      callback();
                    });
                  } else {
                    // player already exists
                    callback();
                  }

                }, function(err) {
                  if(err) {console.error(err); return}

                  // check game result
                  if(!result.bggid) {console.error('Missing bggid for gameresult ', result); return}

                  Gameresult.create({

                    bggid: result.bggid,
                    tournament: tournament._id,
                    time: result.time,
                    scores: _.map(result.players, function(score) {
                      return { name: score.name, score: score.score, player: players[score.name]._id } 
                    }),

                  }, callback);
                  
                });


              }, function(err) {
                if(err) {console.error(err); return}
                console.log('Migration complete!');
              });

            });
          });
        });
      });
    }, 1000);
  }
});

