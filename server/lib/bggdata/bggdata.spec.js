'use strict';

var should = require('should');
var bggdata = require('./bggdata');
var _ = require('lodash');

var zhanguoId = 160495;

describe('bggdata', function() {

  before(function(done) {
    bggdata.cache.clear(function(err) {
      done(err);
    });
  });

  after(function(done) {
    bggdata.cache.clear(function(err) {
      done(err);
    });
  });

  it('#search', function(done) {
    bggdata.search('zhanguo', function(err, res) {

      res.should.be.type('object');
      var zhanGuo = _.find(res, function(item) {return item.id == zhanguoId});
      zhanGuo.should.be.instanceof(Object);

      // test again (should load fromm cache)
      bggdata.search('zhanguo', function(err, res) {

        res.should.be.type('object');
        var zhanGuo = _.find(res, function(item) {return item.id == zhanguoId});
        zhanGuo.should.be.instanceof(Object);

        done();
        
      });
      
    });
  });

  it('#info', function(done) {
    this.timeout = 8 * 1000;

    bggdata.info(zhanguoId, function(err, res) {

      res.should.be.type('object');

      // test again (should load fromm cache)
      bggdata.info(zhanguoId, function(err, res) {

        res.should.be.type('object');
        done();
        
      });
      
    });
  });

});
