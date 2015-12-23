'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var MessageSchema = new Schema({
  recipient: {type : mongoose.Schema.ObjectId, ref : 'User'},
  sender: {type : mongoose.Schema.ObjectId, ref : 'User'},
  time: {type: Date, default: Date.now},
  read: {type: Boolean, default: false},
  type: String,
  msg: String,
  data: Schema.Types.Mixed,
});

module.exports = mongoose.model('Message', MessageSchema);
