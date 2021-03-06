'use strict';

function mongoDbUri() {
  return process.env.MONGODB_HOST ? 'mongodb://' + process.env.MONGODB_HOST + '/shpeely' : null;
}

// Production specific configuration
// =================================
module.exports = {
  // Server IP
  ip:         process.env.OPENSHIFT_NODEJS_IP ||
              process.env.IP ||
              undefined,

  // Server port
  port:       process.env.OPENSHIFT_NODEJS_PORT ||
              process.env.PORT ||
              8080,

  securePort: process.env.SECURE_PORT || 9090,

  // MongoDB connection options
  mongo: {
    uri:      mongoDbUri() || 
              process.env.MONGOLAB_URI ||
              process.env.MONGOHQ_URL ||
              process.env.OPENSHIFT_MONGODB_DB_URL+process.env.OPENSHIFT_APP_NAME ||
              'mongodb://localhost/shpeely'
  },

  seedDB: false
};
