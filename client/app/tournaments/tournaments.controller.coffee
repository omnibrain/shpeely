'use strict'

angular.module 'shpeelyApp'
.controller 'TournamentsCtrl', ($scope, $log, $http, Auth, Tournament, $state) ->

  $scope._ = _
  $scope.user = Auth.getCurrentUser()
  $scope.isLoggedIn = Auth.isLoggedIn
  $scope.tournaments = Tournament.getAll()

  $scope.$watch Tournament.getAll, (newValue, oldValue)->
    $scope.myTournaments = newValue

  $scope.createTournament = (name)->
    return if not name then return
    $http.post('/api/tournaments', {name: name}).then (res)->
      Tournament.add res.data
      $state.go 'tournaments.tournament', {slug: res.data.slug}

  $scope.deleteTournament = (tournament)->
    Tournament.delete(tournament).then ->
      _.remove $scope.myTournaments, (t)-> t._id == tournament._id

  $scope.connectToTournament = (tournament)->
    # TODO
