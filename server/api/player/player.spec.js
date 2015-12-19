'use strict';

var should = require('should');
var app = require('../../app');
var request = require('supertest');
var async = require('async');

var User = require('../user/user.model.js');
var Player = require('../player/player.model.js');
var Tournament = require('../tournament/tournament.model.js');

var user = new User({
  _id: '5672c61cb8410a745e05be6b',
  provider: 'local',
  name: 'Fake User',
  email: 'test@test.com',
  password: 'password'
});

var user2 = new User({
  provider: 'local',
  name: 'Fake User 2',
  email: 'test2@test.com',
  password: 'password'
});

var player = new Player({
  name: 'Fake Player',
  _user: user._id,
})

var player2 = new Player({
  name: 'Fake Player 2',
  _user: user2._id,
})

var tournament = new Tournament({
  name: 'Fake Tournament',
  members: [player._id, player2._id],
});

var token = null;

var wrapSaving = function(doc) {
  return function(callback) {
    doc.save(function(err, doc) {
      callback(err, doc);
    });
  } 
}

describe('POST /api/players/disconnect', function() {

  beforeEach(function(done) {
    async.series([
        wrapSaving(tournament),
        wrapSaving(user),
        wrapSaving(user2),
        wrapSaving(player),
        wrapSaving(player2),
    ], function(err, res) {
      request(app)
        .post('/auth/local')
        .send({email:'test@test.com', password:'password'})
        //.expect(302)
        .end(function(err, res){
          token = res.body.token;
          done(err);
        });
    });
  });

  afterEach(function(done) {
    User.remove().exec().then(function(err, res) {
      Player.remove().exec().then(function() {
        Tournament.remove().exec().then(function() {
          done();
        });
      });
    });
  });

  it('should not disconnect the user from the player because of missing rights', function(done) {
    // precondition
    should.exist(player._user);
    player._user.should.be.equal(user._id);
    request(app)
      .post('/api/players/disconnect')
      .set('Authorization', 'Bearer '  + token)
      .send({player: player2._id})
      .expect(403)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        var player = res.body;
        done();
      });
  });

  it('should disconnect the user from the player with admin rights', function(done) {
    // precondition
    should.exist(player._user);

    player.role = 'admin';
    player.save( function(err, player) {
      player._user.should.be.equal(user._id);
      request(app)
        .post('/api/players/disconnect')
        .set('Authorization', 'Bearer '  + token)
        .send({player: player2._id})
        .expect(200)
        .expect('Content-Type', /json/)
        .end(function(err, res) {
          if (err) return done(err);
          var player = res.body;
          done();
        });
    });
  });


  it('should disconnect the requesting user from his/her player', function(done) {
    // precondition
    should.exist(player._user);
    player._user.should.be.equal(user._id);
    request(app)
      .post('/api/players/disconnect')
      .set('Authorization', 'Bearer '  + token)
      .send({player: player._id})
      .expect(200)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        var player = res.body;
        should.not.exist(player._user);
        done();
      });
  });
});


describe('GET /api/players', function() {

  it('should respond with JSON array', function(done) {
    request(app)
      .get('/api/players')
      .expect(200)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        res.body.should.be.instanceof(Array);
        done();
      });
  });
});
