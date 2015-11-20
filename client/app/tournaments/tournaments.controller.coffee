'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentsCtrl', ($scope, $log, $http, Auth) ->

  $scope._ = _
  $scope.user = Auth.getCurrentUser()

  $http.get('/api/tournaments').success (tournaments) ->

    # check if current user is admin
    for tournament in tournaments
      if $scope.user._id in tournament.admins
        tournament.admin = true

    $scope.tournaments = tournaments

  $scope.createTournament = (form)->
    return if $scope.newTournament is ''
    $http.post '/api/tournaments',
      name: $scope.newTournament
      creator: $scope.user._id
    .then (res)->
      $scope.tournaments.push res.data

    $scope.newTournament = ''

  $scope.isAdmin = (tournament)->
    $scope.user._id in tournament.admins
