/**
 * Main application file
 */

'use strict';

// Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var os = require('os');
var cluster = require('cluster');
var fs = require('fs');
var path = require('path');

var express = require('express');
var mongoose = require('mongoose');
var config = require('./config/environment');

// Connect to database
config.mongo.session = mongoose.connect(config.mongo.uri, config.mongo.options);

// Populate DB with sample data
if(config.seedDB) { require('./config/seed'); }

// migrate data from old website
if(process.env.MIGRATE_SPILI) { require('./config/spilimigration'); }

// Setup Cluster
var app = express();

require('./config/express')(app);
require('./routes')(app);

if(cluster.isMaster) {
  var numWorkers = require('os').cpus().length;

  console.log('Master cluster setting up ' + numWorkers + ' workers...');

  for(var i = 0; i < numWorkers; i++) {
    cluster.fork();
  }

  cluster.on('online', function(worker) {
    console.log('Worker ' + worker.process.pid + ' is online');
  });

  cluster.on('exit', function(worker, code, signal) {
    console.log('Worker ' + worker.process.pid + ' died with code: ' + code + ', and signal: ' + signal);
    console.log('Starting a new worker');
    cluster.fork();
  });

} else {

  // Start HTTPS server if credentials are available
  var server;

  if(process.env.PROTOCOL == 'https') {

    if(!process.env.SSL_KEY || !process.env.SSL_CERT) {
      throw new Error('SSL_KEY and SSL_CERT need to be set when using https');
      return;
    }

    server = require('https').createServer({
      key: fs.readFileSync(process.env.SSL_KEY),
      cert: fs.readFileSync(process.env.SSL_CERT),
    }, app);

    // set up http server that redirects all requests to the https server
    require('http').createServer(app).listen(config.port);

  } else {
    server = require('http').createServer(app);
  }

  // Start server
  var port = process.env.PROTOCOL == 'https' ? config.securePort : config.port;
  server.listen(port, config.ip, function () {
    console.log('Express server (PID %s) listening on %d, in %s mode', process.pid,  port, app.get('env'));
  });


 }

// Expose app
exports = module.exports = app;


