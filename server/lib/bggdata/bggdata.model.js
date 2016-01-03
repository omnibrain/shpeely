'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

// DO NOT CHANGE this model. This is just a mongoose schema for the 
// Cacaheman mongo cache of the BggData. This allows easier querying
// the contents of the mongodb cache.

var BggDataSchema = new Schema({
  key: String,
  expire: Number,
  value: Schema.Types.Mixed,
}, { collection: 'bggdata' });

module.exports = mongoose.model('BggData', BggDataSchema);







