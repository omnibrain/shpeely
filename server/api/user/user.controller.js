'use strict';

var User = require('./user.model');
var passport = require('passport');
var config = require('../../config/environment');
var jwt = require('jsonwebtoken');
var request = require('request');

var validationError = function(res, err) {
  return res.json(422, err);
};

var createUser = function(req, res) {
  var newUser = new User(req.body);
  newUser.provider = 'local';
  newUser.role = 'user';
  newUser.save(function(err, user) {
    if (err) return validationError(res, err);
    var token = jwt.sign({_id: user._id }, config.secrets.session, { expiresInMinutes: 60*5 });
    res.json({token: token });
  });
};

/**
 * Get list of users
 * restriction: 'admin'
 */
exports.index = function(req, res) {
  User.find({}, '-salt -hashedPassword', function (err, users) {
    if(err) return res.send(500, err);
    res.json(200, users);
  });
};


/**
 * Creates a new user
 */
exports.create = function (req, res, next) {

  // validate recaptcha
  if(config.recaptchaSecret && config.recaptchaSitekey) {

    var data = {
      secret: config.recaptchaSecret,
      response: req.body.recaptcha,
      remoteip: req.headers['x-forwarded-for'] || req.connection.remoteAddress
    }

    request.post({url: 'https://www.google.com/recaptcha/api/siteverify', form: data}, function(err, httpResponse, body) {

      try {
        if(JSON.parse(body).success) {
          // success! Create user...
          createUser(req, res);
        } else {
          console.log('Invalid captcha response was provided.');
          res.json(400, {err: 'Invalid captcha'});
        }
      } catch (err) {
        res.json(500, {err: err});
      }
    });
  } else {
    // recaptcha is not configured -> proceed
    createUser(req, res);
  }
};

/**
 * Get a single user
 */
exports.show = function (req, res, next) {
  var userId = req.params.id;

  User.findById(userId, function (err, user) {
    if (err) return next(err);
    if (!user) return res.send(401);
    res.json(user.profile);
  });
};

/**
 * Deletes a user
 * restriction: 'admin'
 */
exports.destroy = function(req, res) {
  User.findByIdAndRemove(req.params.id, function(err, user) {
    if(err) return res.send(500, err);
    return res.send(204);
  });
};

/**
 * Change a users password
 */
exports.changePassword = function(req, res, next) {
  var userId = req.user._id;
  var oldPass = String(req.body.oldPassword);
  var newPass = String(req.body.newPassword);

  User.findById(userId, function (err, user) {
    if(user.authenticate(oldPass)) {
      user.password = newPass;
      user.save(function(err) {
        if (err) return validationError(res, err);
        res.send(200);
      });
    } else {
      res.send(403);
    }
  });
};

/**
 * Get my info
 */
exports.me = function(req, res, next) {
  var userId = req.user._id;
  User.findOne({
    _id: userId
  }, '-salt -hashedPassword', function(err, user) { // don't ever give out the password or salt
    if (err) return next(err);
    if (!user) return res.json(401);
    res.json(user);
  });
};

/**
 * Authentication callback
 */
exports.authCallback = function(req, res, next) {
  res.redirect('/');
};
