'use strict'

angular.module 'boardgametournamentApp'
.controller 'PlayerCtrl', ($scope, $stateParams, Tournament) ->

  $scope.gamePlayerStats = {}
  $scope.gamePlayerStats.columns = [
    {name: 'Game', sortKey: 'game.name'}
    {name: 'Players', sortKey: 'players'}
    {name: 'Games Played', sortKey: 'games'}
    {name: 'Highscore', sortKey: 'highscore'}
    {name: 'Average', sortKey: 'average'}
    {name: 'Lowscore', sortKey: 'lowscore'}
  ]

  $scope.gamePlayerStats.reverse = false
  $scope.gamePlayerStats.activeColumn = $scope.columns[0]
  $scope.gamePlayerStats.loading = true

  $scope.sort = (column)->
    $scope.gamePlayerStats.activeColumn = column
    $scope.gamePlayerStats.reverse = !$scope.gamePlayerStats.reverse

  Tournament.getScores().then (scores)->
    $scope.score = (_.find scores, (score)-> score.player.name == $stateParams.player).score

  $scope.$on 'player_stats_loaded', ->
    $scope.player = _.find $scope.$parent.playerStats, (stats)-> stats.player.name == $stateParams.player

    Tournament.getGamePlayerStats(player: $scope.player.player._id).then (gamePlayerStats)->
      $scope.gamePlayerStats.stats = gamePlayerStats
      $scope.gamePlayerStats.loading = false

