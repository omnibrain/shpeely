'use strict'

angular.module 'boardgametournamentApp'
.controller 'MainCtrl', ($scope, $http, Tournament) ->

  $scope.allTournaments = []

  $scope.lead = _.sample [
    'Forget everything you thought was important. This is what counts now.',
    'Boardgaming just became serious.',
    'Statistics don\'t lie',
  ]
  
  Tournament.getTournaments().then (tournaments)->
    $scope.allTournaments = tournaments

  $scope.search = ->
    $scope.loading = true

    if not $scope.query or not $scope.query.length then return

    Tournament.search($scope.query).then (found)->
      console.log found
      $scope.loading = false
      $scope.foundTournaments = found

