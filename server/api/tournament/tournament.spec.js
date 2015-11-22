'use strict';

var should = require('should');
var app = require('../../app');
var request = require('supertest');
var User = require('../user/user.model.js');
var Player = require('../player/player.model.js');
var Tournament = require('../tournament/tournament.model.js');

var user = new User({
  provider: 'local',
  name: 'Fake User',
  email: 'test@test.com',
  password: 'password'
});

var player = new Player({
  name: 'Fake Player',
  _user: user._id,
})

var tournament = new Tournament({
  name: 'Fake Tournament',
  members: [player._id],
});

var token = null;

describe('GET /api/tournaments/mine', function() {

  before(function(done) {
    user.save(function() {
      player.save( function() {
        tournament.save( function() {
          // authenticate user
          request(app)
            .post('/auth/local')
            .send({email:'test@test.com', password:'password'})
            .expect(302)
            .end(function(err, res){
              token = res.body.token;
              done();
            });
        });
      });
    });
  });

  after(function(done) {
    User.remove().exec().then(function() {
      Player.remove().exec().then(function() {
        Tournament.remove().exec().then(function() {
          done();
        });
      });
    });
  });

  it('should return all tournements of the user', function(done) {
    request(app)
      .get('/api/tournaments/mine')
      .expect(200)
      .set('Authorization', 'Bearer '  + token)
      .end(function(err, res) {
        if (err) return done(err);
        console.log(res.body);
        res.body.should.be.instanceof(Array).and.have.lengthOf(1);
        done();
      });
  });

  it('should return all tournements of the user that match the query', function(done) {
    request(app)
      .get('/api/tournaments/mine')
      .query({name: 'Fake Tournament'})
      .expect(200)
      .set('Authorization', 'Bearer '  + token)
      .end(function(err, res) {
        if (err) return done(err);
        console.log(res.body);
        res.body.should.be.instanceof(Array).and.have.lengthOf(1);
        done();
      });
  });

});

describe('POST /api/tournaments', function() {

  before(function(done) {
    user.save(function() {
      // authenticate user
      request(app)
        .post('/auth/local')
        .send({email:'test@test.com', password:'password'})
        .expect(302)
        .end(function(err, res){
          token = res.body.token;
          done();
        });
    });
  });

  afterEach(function(done) {
    User.remove().exec().then(function() {
      done();
    });
  });

  it('should respond with the created tournament object', function(done) {

    var tournament = {
      name: 'Test Tournament',
    }

    request(app)
      .post('/api/tournaments')
      .set('Authorization', 'Bearer '  + token)
      .send(tournament)
      .expect(201)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        var tournament1 = res.body;
        tournament1.name.should.be.equal(tournament.name)

        // Create another tourament with the same name
        request(app)
          .post('/api/tournaments')
          .set('Authorization', 'Bearer '  + token)
          .send(tournament)
          .expect(201)
          .expect('Content-Type', /json/)
          .end(function(err, res) {
            if (err) return done(err);
            var tournament2 = res.body;
            tournament2.name.should.be.equal(tournament.name)

            // check slugs
            tournament2.slug.should.be.not.equal(tournament1.slug);

            done();
          });

      });
  });
});
