'use strict'

angular.module 'shpeelyApp'
.factory 'Player', ($resource)->
  $resource '/api/players/:id/:controller',
    id: '@_id'
  , {}
