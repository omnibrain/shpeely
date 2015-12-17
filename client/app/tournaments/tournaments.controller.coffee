'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentsCtrl', ($scope, $log, $http, Auth, Tournament) ->

  $scope._ = _
  $scope.user = Auth.getCurrentUser()

  $scope.myTournaments

  $http.get('/api/tournaments/mine').success (tournaments) ->
    $scope.myTournaments = tournaments

  $scope.createTournament = (form)->
    return if $scope.newTournament is ''
    $http.post '/api/tournaments',
      name: $scope.newTournament
    .then (res)->
      Tournament.add res.data
      $scope.myTournaments.push res.data

    $scope.newTournament = ''

