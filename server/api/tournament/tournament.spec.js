'use strict';

var should = require('should');
var app = require('../../app');
var request = require('supertest');
var User = require('../user/user.model.js');

var user = new User({
  provider: 'local',
  name: 'Fake User',
  email: 'test@test.com',
  password: 'password'
});

describe('POST /api/tournaments', function() {

  before(function(done) {
    user.save(function() {
      done();
    });
  });

  afterEach(function(done) {
    User.remove().exec().then(function() {
      done();
    });
  });

  it('should respond with the created tournament object', function(done) {

    // find a user
    User.find({}, function(err, users) {
      var user = users[0];

      var tournament = {
        creator: user._id,
        name: 'Test Tournament',
      }

      request(app)
        .post('/api/tournaments')
        .send(tournament)
        .expect(201)
        .expect('Content-Type', /json/)
        .end(function(err, res) {
          if (err) return done(err);
          res.body.name.should.be.equal(tournament.name)
          done();
        });

    });
  });
});
