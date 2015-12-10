'use strict'

angular.module 'boardgametournamentApp'
.controller 'PlayersCtrl', ($scope, Tournament) ->

  $scope.loading = true

  $scope.reverse = false

  $scope.columns = [
    {name: 'Player', sortKey: 'player.name'}
    {name: 'Games', sortKey: 'games'}
    {name: 'Win Ratio', sortKey: 'winRatio'}
    {name: 'Lose Ratio', sortKey: 'loseRatio'}
    {name: 'Wins', sortKey: 'wins'}
    {name: 'Losses', sortKey: 'losses'}
  ]

  $scope.activeColumn = $scope.columns[0]

  $scope.sort = (column)->
    $scope.activeColumn = column
    $scope.reverse = !$scope.reverse

  Tournament.getPlayerStats().then (playerStats)->
    console.log playerStats
    $scope.playerStats = playerStats
    $scope.loading = false




