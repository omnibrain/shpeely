'use strict'

angular.module 'shpeelyApp'
.factory 'GameResult', ($resource)->
  $resource '/api/gameresults/:id',
    id: '@_id'
