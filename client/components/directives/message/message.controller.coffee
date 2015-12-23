'use strict'

angular.module 'boardgametournamentApp'
.controller 'MessageCtrl', ($scope) ->

  $scope.titles =
   'claim-player-request': 'Tournament Membership Request'

  $scope.content =
   'claim-player-request': (message)->
     message

  console.log "msg dir"
