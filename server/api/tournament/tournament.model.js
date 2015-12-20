'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var slug = require('mongoose-url-slugs');

var TournamentSchema = new Schema({
  name: {type: String, required: true, maxlength: 50},
  active: {type: Boolean, default: true, required: true},
  created: {type: Date, default: Date.now, required: true},
  members: [ {type : mongoose.Schema.ObjectId, ref : 'Player'} ],
  lastEdit: {type: Date}
});


TournamentSchema.plugin(slug('name'));
module.exports = mongoose.model('Tournament', TournamentSchema);

