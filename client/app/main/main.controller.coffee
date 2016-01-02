'use strict'

angular.module 'shpeelyApp'
.controller 'MainCtrl', ($scope, $http, Tournament, Auth) ->

  $scope.allTournaments = []

  $scope.isLoggedIn = Auth.isLoggedIn

  $scope.lead = _.sample [
    'Forget everything you thought was important. This is what counts now.',
    'Boardgaming just became serious.',
    'Statistics don\'t lie',
  ]
  
  Tournament.getTournaments().then (tournaments)->
    $scope.allTournaments = tournaments

  $scope.search = ->

    if not $scope.query or not $scope.query.length
      $scope.foundTournaments = null
      return

    $scope.loading = true

    Tournament.search($scope.query).then (found)->
      console.log found
      $scope.loading = false
      $scope.foundTournaments = found

  $scope.deleteTournament = (tournament)->
    Tournament.delete(tournament).then (res)->
      console.log res
      _.remove $scope.allTournaments, (t)-> t._id == tournament._id
      _.remove $scope.foundTournaments, (t)-> t._id == tournament._id


