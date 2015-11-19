'use strict';

var express = require('express');
var controller = require('./bgg.controller');

var router = express.Router();

router.get('/search', controller.search);
router.get('/info', controller.info);

module.exports = router;
