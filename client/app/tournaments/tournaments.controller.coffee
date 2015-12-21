'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentsCtrl', ($scope, $log, $http, Auth, Tournament, $state) ->

  $scope._ = _
  $scope.user = Auth.getCurrentUser()

  $scope.isLoggedIn = Auth.isLoggedIn

  $scope.tournaments = Tournament.getAll()

  $scope.$watch Tournament.getAll, (newValue, oldValue)->
    console.log "tournaments!"
    console.log newValue
    $scope.myTournaments = newValue

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
