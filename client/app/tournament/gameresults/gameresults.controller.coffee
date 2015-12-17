'use strict'

angular.module 'boardgametournamentApp'
.controller 'GameresultsCtrl', ($scope, Tournament) ->

  $scope.limitTo = 12

  $scope.debounce = 350

  $scope.filter =
    game: ''
    player: ''
    numberOfPlayers: ''
