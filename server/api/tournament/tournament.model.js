'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var TournamentSchema = new Schema({
  name: {type: String, required: true},
  active: {type: Boolean, default: true, required: true},
  created: {type: Date, default: Date.now, required: true},
  members: [ {type : mongoose.Schema.ObjectId, ref : 'Player'} ],
});

module.exports = mongoose.model('Tournament', TournamentSchema);
