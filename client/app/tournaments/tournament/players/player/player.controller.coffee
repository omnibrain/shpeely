'use strict'

angular.module 'shpeelyApp'
.controller 'PlayerCtrl', ($scope, $stateParams, Tournament) ->

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

  $scope.highscores = []
  $scope.lowscores = []


  displayStats = (playerStats)->
    if not playerStats then return

    $scope.player = _.find playerStats, (stats)-> stats.player.name == $stateParams.player
    Tournament.getGamePlayerStats(player: $scope.player.player._id).then (gamePlayerStats)->
      $scope.gamePlayerStats = gamePlayerStats

  displayScore = (scores)->
    if not scores then return
    $scope.score = (_.find scores, (score)-> score.player.name == $stateParams.player).score

  displayHighLowScores = (gameStats)->
    if not gameStats then return

    $scope.highscores = _.chain(gameStats)
      .filter (item)-> item.highscore.player.name == $stateParams.player
      .map (item)-> {game: item.game, players: item.players, score: item.highscore.score }
      .value()

    $scope.lowscores = _.chain(gameStats)
      .filter (item)-> item.lowscore.player.name == $stateParams.player
      .map (item)-> {game: item.game, players: item.players, score: item.lowscore.score }
      .value()


  $scope.$watch 'playerStats', displayStats
  $scope.$watch 'scores', displayScore
  $scope.$watch 'gameStats', displayHighLowScores

  displayStats($scope.playerStats)
  displayScore($scope.scores)
  displayHighLowScores($scope.gameStats)

    

