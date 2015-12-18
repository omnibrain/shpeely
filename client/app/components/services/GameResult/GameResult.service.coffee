'use strict'

angular.module 'boardgametournamentApp'
.factory 'GameResult', ($resource)->
  $resource '/api/gameresults/:id',
    id: '@_id'
