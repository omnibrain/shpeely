'use strict'

angular.module 'shpeelyApp'
.controller 'GameresultsCtrl', ($scope, Tournament) ->

  $scope.limitTo = 10

  $scope.debounce = 350

  $scope.filter =
    game: ''
    player: ''
    numberOfPlayers: ''
