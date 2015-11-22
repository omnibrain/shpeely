'use strict';

var express = require('express');
var controller = require('./tournament.controller');
var auth = require('../../auth/auth.service.js');

var router = express.Router();

router.get('/', controller.index);
router.get('/mine', auth.isAuthenticated(), controller.mine);
router.get('/:id', controller.show);

router.get('/:id/gameresults', controller.gameresults);
router.get('/:id/games', controller.games);
router.get('/:id/players', controller.players);

module.exports = router;
