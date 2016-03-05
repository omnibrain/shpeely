'use strict'

angular.module 'shpeelyApp'
.controller 'GameresultsCtrl', ($scope, Tournament) ->

  $scope.limitTo = 10

  $scope.debounce = 350

  $scope.filter =
    game: null
    players: null
    numberOfPlayers: null

  $scope.resetFilter = -> $scope.filter = {}

  $scope.changeLimit = (newLimit)-> $scope.limitTo = newLimit

  $scope.gameSelectizeConfig =
    valueField: 'game',
    labelField: 'game',
    searchField: 'game',
    placeholder: 'Search for Game',
    maxItems: 1

  $scope.playersSelectizeConfig =
    valueField: 'name',
    labelField: 'name',
    searchField: 'name',
    placeholder: 'Search for Players',

  $scope.numPlayerOptions = ({value: i, label: i} for i in (_.range 1, 11))
  $scope.numPlayerSelectizeConfig =
    valueField: 'value',
    labelField: 'label',
    placeholder: 'Number of Players',
    maxItems: 1

  $scope.$watch 'gameResults', (gameResults)->
    # check the actual number of players of all played games
    # and only show them in the dropdown
    if not gameResults then return
    numPlayerSet = _.chain gameResults
      .map (e)-> e.scores.length
      .uniq()
      .sort()
      .value()
    $scope.numPlayerOptions = ({value: i, label: i} for i in numPlayerSet)

  $scope.$watch 'gameStats', (stats)->
    if not stats then return
    $scope.gameOptions = _.chain stats
      .map 'game.name'
      .uniq()
      .sort()
      .map (game)-> {game: game}
      .value()
