'use strict'

angular.module 'boardgametournamentApp'
.factory 'Player', ($resource)->
  $resource '/api/players/:id/:controller',
    id: '@_id'
  , {}
