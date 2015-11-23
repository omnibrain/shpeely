'use strict';

var should = require('should');
var app = require('../../app');
var request = require('supertest');

var should = require('should');
var app = require('../../app');
var request = require('supertest');
var Tournament = require('../tournament/tournament.model.js');
var Player = require('../player/player.model.js');
var Gameresult = require('../gameresult/gameresult.model.js');
var ultimatescre = require('../../lib/ultimatescore.js');
var _ = require('lodash');
var async = require('async');

var zhanguoId = 160495;

var player = new Player({
  name: 'Fake Player',
  role: 'member',
});

var players = _.map(_.range(10), function(i) {
  return new Player({
    name: 'Fake Player ' + i,
  });
});

var tournament = new Tournament({
  name: 'Fake Tournament',
  members: players.concat(player)
});

var gameResults = _.map(_.range(10), function(i) {
  var playersPerGame = 3
  var selectedPlayers = _.sample(players, playersPerGame);
  return new Gameresult({
    bggid: zhanguoId,
    tournament: tournament._id,
    scores: _.map(_.range(playersPerGame), function(j) {
      return {
        player: selectedPlayers[j],
        score: Math.round(Math.random() * 100),
      };
    }),
  });
});


describe('ultimatescore', function() {

  before(function(done) {
    tournament.save( function() {
      async.each(players, function(player, callback) {
        player.save(callback);
      }, function(err) {
        async.each(gameResults, function(gameResult, callback) {
          gameResult.save(callback) ;
        }, function() {
          done();
        });
      });
    });
  });

  after(function(done) {
    Player.remove().exec().then(function() {
      Tournament.remove().exec().then(function() {
        Gameresult.remove().exec().then(function() {
          done();
        });
      });
    });
  });

  it('#computeScores (should compute the scores)', function(done) {

    this.timeout(30000);

    request(app)
      .get('/api/scores/' + tournament._id)
      .expect(200)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        res.body.should.be.instanceof(Array).and.have.lengthOf(players.length);

        // do it again -> should load from cache
        request(app)
          .get('/api/scores/' + tournament._id)
          .expect(200)
          .expect('Content-Type', /json/)
          .end(function(err, res) {
            if (err) return done(err);
            res.body.should.be.instanceof(Array);
            res.body.length.should.be.within(3, players.length);

            done();
          });

      });
  });
});
