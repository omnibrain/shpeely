
var mongodb = require('mongodb');

// migrates the old game results to the new database

exports.up = function(db, next){
  console.log('UP');
  // Connect to the spili database
  mongodb.MongoClient.connect("mongodb://localhost:27017/spili", function(err, spiliDb) {
    if(!err) {
      console.log("We are connected");
    }
})
  next();
};

exports.down = function(db, next){
  console.log('DOWN');
  next();
};
