'use strict'

angular.module 'boardgametournamentApp'
.controller 'GameResultEditCtrl', ($scope, GameResult, BggApi, $http, Tournament, $timeout, $state) ->

  # WARNING:  this controller is quite the hack. Basically
  # all the functionality of the tournament.controller is
  # used here, with the same scope variables. Less code to write...
  # Better solution would be to have this functionality in a
  # dedicated service...
  
  $scope.newGameResult = {}

  adaptNumPlayers = (bgginfo)->
    if not bgginfo then return
    # add or remove score rows
    numPlayersDelta = $scope.newGameResult.scores.length - bgginfo.maxPlayers
    if numPlayersDelta < 0
      $scope.newGameResult.scores.push {} for i in _.range(0, -numPlayersDelta)
    else if numPlayersDelta > 0
      $scope.newGameResult.scores = $scope.newGameResult.scores[0...bgginfo.maxPlayers]
      console.log $scope.newGameResult

  $scope.delete = ->
    $http.delete("api/gameresults/#{$scope.gameresult._id}").then ->
      $scope.deleted = true

  $scope.undoDelete = ->
    $http.post("api/gameresults", $scope.gameresult).then ->
      $scope.deleted = false

  $scope.saveChanges = ->
    $http.patch("/api/gameresults/#{$scope.newGameResult._id}", $scope.newGameResult).then (res)->
      Tournament.cache(false)
      $scope.saved = true
      $timeout ->
        $scope.saved = false
      , 3000
    , ->
      $scope.error = res.data.err

  fillFields = (gameresult)->
    if not gameresult then return
    
    # change player docs to ids
    newGameResult = angular.copy gameresult
    newGameResult.scores = _.map newGameResult.scores, (score)->
      score.player = score.player._id
      score

    $scope.getBggInfo newGameResult.bggid
    $scope.gameSelectizeConfig.load newGameResult.game.name, (options)->
      $scope.gameOptions = options

    $scope.newGameResult = newGameResult

  fillFields($scope.gameresult)
  $scope.$watch 'gameresult', fillFields
  $scope.$watch 'bgginfo', adaptNumPlayers
