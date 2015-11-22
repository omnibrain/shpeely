'use strict';

var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var slug = require('mongoose-url-slugs');

var TournamentSchema = new Schema({
  name: {type: String, required: true},
  active: {type: Boolean, default: true, required: true},
  created: {type: Date, default: Date.now, required: true},
  members: [ {type : mongoose.Schema.ObjectId, ref : 'Player'} ],
  slug: {type: String, required: false}
});

TournamentSchema.plugin(slug('name'));
module.exports = mongoose.model('Tournament', TournamentSchema);
