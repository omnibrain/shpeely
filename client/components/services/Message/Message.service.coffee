'use strict'

angular.module 'boardgametournamentApp'
.factory 'Message', ($resource)->
  $resource '/api/messages/:id/:controller',
    id: '@_id'
  , {}
