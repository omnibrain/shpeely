'use strict'

angular.module 'boardgametournamentApp'
.controller 'GameCtrl', ($scope, $http, $stateParams) ->

  # load bgg info for this game
  $http.get("/api/bgg/info", {cache: true, params: {bggid: $stateParams.bggid}}).then (res)->
    console.log res.data

  $scope.columns = [
    {name: 'Game', sortKey: 'game.name'}
    {name: 'Players', sortKey: 'players'}
    {name: 'Games Played', sortKey: 'games'}
    {name: 'Highscore', sortKey: 'highscore'}
    {name: 'Average', sortKey: 'average'}
    {name: 'Lowscore', sortKey: 'lowscore'}
  ]

  $scope.reverse = false
  $scope.activeColumn = $scope.columns[0]

  $scope.sort = (column)->
    $scope.activeColumn = column
    $scope.reverse = !$scope.reverse
