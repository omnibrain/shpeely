'use strict'

angular.module 'boardgametournamentApp'
.controller 'DashboardCtrl', ($scope, Tournament) ->

  $scope.reverse = false
  $scope.columns = [
    {name: 'Player', sortKey: 'member.name'}
    {name: 'Role', sortKey: 'member.role'}
    {name: 'Name', sortKey: 'member.role'}
    {name: 'Actions', sortKey: ''}
  ]

  $scope.memberFilter = (value, index, array)-> !!value._user

  $scope.sort = (column)->
    $scope.activeColumn = column
    $scope.reverse = !$scope.reverse

  $scope.activeTournament = Tournament.getActive()

  console.log $scope.activeTournament.members
