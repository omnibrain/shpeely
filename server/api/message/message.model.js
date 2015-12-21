'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var MessageSchema = new Schema({
  recipient: {type : mongoose.Schema.ObjectId, ref : 'User'},
  sender: {type : mongoose.Schema.ObjectId, ref : 'User'},
  read: {type: Boolean, default: false},
  type: String,
  msg: String,
  data: Schema.Type.Mixed,
});

module.exports = mongoose.model('Message', MessageSchema);
