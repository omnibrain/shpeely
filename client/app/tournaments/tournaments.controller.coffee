'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentsCtrl', ($scope, $log, $http, Auth, Tournament, $state) ->

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
      $state.go 'tournament', {slug: res.data.slug}
      $scope.myTournaments.push res.data

    $scope.newTournament = ''

  $scope.deleteTournament = (tournament)->
    Tournament.delete(tournament).then ->
      _.remove $scope.myTournaments, (t)-> t._id == tournament._id
