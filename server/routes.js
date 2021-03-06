/**
 * Main application routes
 */

'use strict';

var errors = require('./components/errors');

module.exports = function(app) {

  // Insert routes below
  app.use('/api/messages', require('./api/message'));
  app.use('/api/scores', require('./api/score'));
  app.use('/api/gameresults', require('./api/gameresult'));
  app.use('/api/players', require('./api/player'));
  app.use('/api/bgg', require('./api/bgg'));
  app.use('/api/tournaments', require('./api/tournament'));
  app.use('/api/users', require('./api/user'));

  app.use('/auth', require('./auth'));
  
  // All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*')
   .get(errors[404]);

  // All other routes should redirect to the index.html
  app.route('/*')
    .get(function(req, res) {
      res.sendfile(app.get('appPath') + '/index.html');
    });
};
