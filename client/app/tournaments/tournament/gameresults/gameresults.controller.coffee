'use strict'

angular.module 'shpeelyApp'
.controller 'GameresultsCtrl', ($scope, Tournament) ->

  $scope.limitTo = 10

  $scope.debounce = 350

  $scope.filter =
    game: null
    players: null
    numberOfPlayers: null

  $scope.test = ->
    console.log "mkay"

  $scope.changeLimit = (newLimit)->
    $scope.limitTo = newLimit

  

  $scope.playersSelectizeConfig =
    valueField: 'name',
    labelField: 'name',
    searchField: 'name',
    placeholder: 'Search for Players',

  $scope.numPlayerOptions = ({value: i, label: i} for i in (_.range 1, 11))

  #$scope.$watch 'players', (players)->
    #if players and players.length
    #$scope.players - 

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
