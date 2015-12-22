'use strict'

angular.module 'boardgametournamentApp'
.controller 'GamesCtrl', ($scope, Tournament) ->

  $scope.reverse = false

  $scope.columns = [
    {name: 'Game', sortKey: 'game.name'}
    {name: 'Players', sortKey: 'players'}
    {name: 'Games', sortKey: 'totalGames'}
    {name: 'Highscore', sortKey: 'highscore.player.name'}
    {name: 'Average', sortKey: 'averageScore'}
    {name: 'Lowscore', sortKey: 'lowscore.player.name'}
    {name: 'Highest Win Ratio', sortKey: 'playerWithHighestWinRatio.name'}
  ]

  $scope.activeColumn = $scope.columns[0]

  $scope.sort = (column)->
    $scope.activeColumn = column
    $scope.reverse = !$scope.reverse




