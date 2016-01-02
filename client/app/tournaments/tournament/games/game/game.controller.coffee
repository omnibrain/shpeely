'use strict'

angular.module 'shpeelyApp'
.controller 'GameCtrl', ($scope, $http, $stateParams, BggApi, Tournament) ->

  bggid = Number($stateParams.bggid)

  $scope.gameSpecificStats = null

  # load bgg info for this game
  BggApi.info(bggid).then (bgginfo)->
    $scope.bgginfo = bgginfo

  getGameSpecificStats = (gameStats)->
    if not gameStats then return
    $scope.gameSpecificStats = _.filter gameStats, (stats)-> stats.game.id == bggid

  # get game statistics
  $scope.$watch 'gameStats', getGameSpecificStats

  $scope.columns = [
    {name: 'Players', sortKey: 'players'}
    {name: 'Games Played', sortKey: 'totalGames'}
    {name: 'Highscore', sortKey: 'highscore.score'}
    {name: 'Average', sortKey: 'averageScore'}
    {name: 'Lowscore', sortKey: 'lowscore.score'}
  ]

  $scope.reverse = false
  $scope.activeColumn = $scope.columns[0]

  $scope.sort = (column)->
    $scope.activeColumn = column
    $scope.reverse = !$scope.reverse
