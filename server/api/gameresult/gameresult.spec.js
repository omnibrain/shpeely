'use strict';

var should = require('should');
var app = require('../../app');
var request = require('supertest');
var Tournament = require('../tournament/tournament.model.js');
var Player = require('../player/player.model.js');


var player = new Player({
  name: 'Fake Player',
  role: 'member',
});

var tournament = new Tournament({
  name: 'Fake Tournament',
  members: [player._id],
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

  it('should respond with the created game result', function(done) {

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
        done();
      });
  });
});
