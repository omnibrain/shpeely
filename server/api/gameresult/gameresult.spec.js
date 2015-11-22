'use strict';

var should = require('should');
var app = require('../../app');
var request = require('supertest');
var Tournament = require('../tournament/tournament.model.js');
var Player = require('../player/player.model.js');
var Gameresult = require('../gameresult/gameresult.model.js');
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
  return new Gameresult({
    bggid: zhanguoId,
    tournament: tournament._id,
    scores: _.map(_.range(3), function(j) {
      return {
        player: players[i % players.length],
        score: Math.round(Math.random() * 100),
      };
    }),
  });
});

describe('MODEL tests', function() {

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

  it('#players (should return all players)', function(done) {
    Gameresult.players({}, function(err, res) {
      res.should.be.instanceof(Array).and.have.lengthOf(players.length)
      res[0]._id.should.be.ok
      res[0].name.should.be.ok
      done();
    });
  });

  it('#games (should return all games)', function(done) {
    Gameresult.games({}, function(err, res) {
      res.should.be.instanceof(Array).and.have.lengthOf(1)
      res[0].id.should.be.equal(zhanguoId);
      done();
    });
  });

  it('#scores (should return all scores)', function(done) {
    Gameresult.scores({}, function(err, res) {
      res.should.be.ok;
      res.should.be.instanceof(Array).and.have.lengthOf(30);
      res[0].should.be.instanceof(Number);
      done();
    });
  });

  it('#gamePlayerStats (Should return player stats for each game)', function(done) {
    Gameresult.gamePlayerStats({}, null, function(err, res) {
      console.log(res);
      res.should.be.ok;
      res.should.be.instanceof(Array).and.have.lengthOf(10);

      // now for a specific player
      Gameresult.gamePlayerStats({}, players[0]._id, function(err, res) {
        console.log(res);
        res.should.be.ok;
        res.should.be.instanceof(Array).and.have.lengthOf(1);
        done();
      });
    });
  });

});

describe('GET /api/gameresults', function() {

  before(function(done) {
    player.save(function() {
      tournament.save(function() {
        done();
      });
    });
  });

  afterEach(function(done) {
    Player.remove().exec().then(function() {
      Tournament.remove().exec().then(function() {
        done();
      });
    });
  });


  it('#create (should respond with the created game result)', function(done) {

    var gameresult = {
      bggid: 777,
      tournament: tournament._id,
      scores: [
        {score: 7, player: player._id},
        {score: 8, player: 'New Player'}
      ] 
    }

    request(app)
      .post('/api/gameresults')
      .send(gameresult)
      .expect(201)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        res.body.bggid.should.be.equal(gameresult.bggid);
        res.body.tournament.should.be.equal(String(tournament._id));
        res.body.scores.should.be.instanceof(Array);

        // check that newly created player is in tournament
        Tournament.findOne({_id: tournament._id}, function(err, tournament) {
          tournament.members.should.be.instanceof(Array).and.have.lengthOf(2);
          done();
        });

      });
  });

});
