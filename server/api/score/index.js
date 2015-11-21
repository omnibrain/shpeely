'use strict';

var express = require('express');
var controller = require('./score.controller');

var router = express.Router();

router.get('/:tournament', controller.index);
router.get('/timeseries/:tournament', controller.timeseries);

module.exports = router;
