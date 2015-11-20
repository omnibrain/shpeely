'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentsCtrl', ($scope, $log, $http, Auth) ->

  $scope._ = _
  $scope.user = Auth.getCurrentUser()

  $scope.tournaments = []

  $http.get('/api/tournaments/mine').success (tournaments) ->
    $scope.tournaments = tournaments

  $scope.createTournament = (form)->
    return if $scope.newTournament is ''
    $http.post '/api/tournaments',
      name: $scope.newTournament
    .then (res)->
      console.log res
      console.log $scope.tournaments
      $scope.tournaments.push res.data

    $scope.newTournament = ''

  $scope.isAdmin = (tournament)->
    _.find(tournament.members, (member)-> member._user == $scope.user._id)?.role == 'admin'
