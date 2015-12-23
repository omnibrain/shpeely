'use strict';

var express = require('express');
var controller = require('./message.controller');

var router = express.Router();

var auth = require('../../auth/auth.service.js');

router.post('/claimPlayer', auth.isAuthenticated(), controller.claimPlayer);
router.get('/:id/acceptMembershipRequest', auth.isAuthenticated(), controller.acceptMembershipRequest);
router.get('/:id/denyMembershipRequest', auth.isAuthenticated(), controller.denyMembershipRequest);
router.get('/', auth.isAuthenticated(), controller.index);
router.get('/count', auth.isAuthenticated(), controller.count);
router.get('/:id', controller.show);
router.get('/:id', controller.show);
router.post('/', controller.create);
router.post('/:id', controller.update);
router.delete('/:id', controller.destroy);

module.exports = router;
