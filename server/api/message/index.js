'use strict';

var express = require('express');
var controller = require('./message.controller');

var router = express.Router();

var auth = require('../../auth/auth.service.js');

router.post('/claimPlayer', auth.isAuthenticated(), controller.claimPlayer);
router.get('/', auth.isAuthenticated(), controller.index);
router.get('/:id', controller.show);
router.get('/:id', controller.show);
router.post('/', controller.create);
router.put('/:id', controller.update);
router.patch('/:id', controller.update);
router.delete('/:id', controller.destroy);

module.exports = router;