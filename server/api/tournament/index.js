'use strict';

var express = require('express');
var controller = require('./tournament.controller');
var auth = require('../../auth/auth.service.js');

var router = express.Router();

router.get('/', controller.index);
router.get('/mine', auth.isAuthenticated(), controller.mine);
router.get('/:id', controller.show);
router.get('/:id/users', auth.isAuthenticated(), controller.users);
router.get('/search/:searchString', controller.search);
router.post('/', auth.isAuthenticated(), controller.create);
//router.put('/:id', controller.update);
//router.patch('/:id', controller.update);
router.delete('/:id', auth.isAuthenticated(), controller.destroy);


router.get('/:id/gameresults', controller.gameresults);
router.get('/:id/games', controller.games);
router.get('/:id/players', controller.players);
router.get('/:id/gamePlayerStats', controller.gamePlayerStats);


module.exports = router;
