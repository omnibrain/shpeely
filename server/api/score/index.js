'use strict';

var express = require('express');
var controller = require('./score.controller');

var router = express.Router();

router.get('/:tournament', controller.index);
router.get('/timeseries/:tournament', controller.timeseries);
router.get('/gameresult/:gameresult', controller.gameresult);

module.exports = router;
