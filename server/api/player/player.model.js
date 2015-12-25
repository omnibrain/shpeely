'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var PlayerSchema = new Schema({
  name: {type: String, required: true},
  role: {type: String, required: true, default: 'member'}, // member/admin
  _user: {type : mongoose.Schema.ObjectId, ref : 'User'}
});

module.exports = mongoose.model('Player', PlayerSchema);
