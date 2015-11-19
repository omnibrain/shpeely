'use strict';

var _ = require('lodash');
var bggdata = require('../../lib/bggdata.js');

exports.search = function(req, res) {

  bggdata.search(req.query.query, function(err, data) {
    if(err) { return handleError(res, err); }
    return res.json(200, data);
  });

};

exports.info = function(req, res) {
  bggdata.info(req.query.bggid, function(err, data) {
    if(err) { return handleError(res, err); }
    return res.json(200, data);
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
