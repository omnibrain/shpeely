'use strict';

var express = require('express');
var controller = require('./gameresult.controller');

var router = express.Router();

var auth = require('../../auth/auth.service.js');

router.get('/', controller.index);
router.get('/:id', controller.show);
router.post('/', controller.create);
router.put('/:id', controller.update);
router.patch('/:id', controller.update);
router.delete('/:id', auth.isAuthenticated(), controller.destroy);

module.exports = router;
