'use strict'

angular.module 'boardgametournamentApp'
.controller 'GameresultCtrl', ($scope, GameResult, $stateParams, $http) ->

  GameResult.get {id: $stateParams.gameresult}, (gameresult)->
    $scope.gameresult = gameresult

  $http.get("/api/scores/gameresult/#{$stateParams.gameresult}").then (res)->
    $scope.gameResultScores = res.data
