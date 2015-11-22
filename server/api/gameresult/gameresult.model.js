'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var GameresultSchema = new Schema({
  bggid: {type: Number, required: true},
  tournament: {type : mongoose.Schema.ObjectId, ref : 'Tournament', required: true},
  time: {type: Date, default: Date.now},
  scores: [{
    score: Number,
    player: {type : mongoose.Schema.ObjectId, ref : 'Player'}
  }]
});

module.exports = mongoose.model('Gameresult', GameresultSchema);
