'use strict';

var express = require('express');
var controller = require('./gameresult.controller');

var router = express.Router();

var playerAuth = require('./playerAuth.service.js');

router.get('/', controller.index);
router.get('/:id', controller.show);
router.post('/', controller.create);
router.put('/:id', playerAuth.hasPlayerRole('admin'), controller.update);
router.patch('/:id', playerAuth.hasPlayerRole('admin'), controller.update);
router.delete('/:id', playerAuth.hasPlayerRole('admin'), controller.destroy);

module.exports = router;
