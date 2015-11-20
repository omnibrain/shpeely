'use strict';

var express = require('express');
var controller = require('./tournament.controller');
var auth = require('../../auth/auth.service.js');

var router = express.Router();

router.get('/', auth.isAuthenticated(), controller.index);
router.get('/mine', auth.isAuthenticated(), controller.mine);
router.get('/:id', controller.show);
router.post('/', auth.isAuthenticated(), controller.create);
router.put('/:id', controller.update);
router.patch('/:id', controller.update);
router.delete('/:id', controller.destroy);

module.exports = router;
