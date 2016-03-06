'use strict';

var express = require('express');
var controller = require('./player.controller');
var auth = require('../../auth/auth.service.js');

var router = express.Router();

router.get('/', controller.index);
router.get('/:id', controller.show);
router.post('/', controller.create);
router.post('/disconnect', auth.isAuthenticated(), controller.disconnect);
router.post('/promote', auth.isAuthenticated(), controller.promote);
router.post('/demote', auth.isAuthenticated(), controller.demote);
//router.put('/:id', controller.update);
//router.patch('/:id', controller.update);
//router.delete('/:id', controller.destroy);

module.exports = router;
