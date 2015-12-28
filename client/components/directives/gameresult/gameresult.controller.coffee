'use strict'

angular.module 'boardgametournamentApp'
.controller 'GameResultCtrl', ($scope, Tournament, $timeout, $http) ->

  $scope.chartLoading = true
  $scope.deleted = false

  loaded = false

  $scope.delete = ->
    $http.delete("api/gameresults/#{$scope.gameresult._id}").then ->
      $scope.deleted = true

  # get the role of the player of the currently logged in user 
  Tournament.getOwnPlayer $scope.gameresult.tournament, (player)->
    $scope.ownRole = player.role


  showChart = (gameresult)->
    if (not gameresult) or loaded then return

    loaded = true

    Tournament.getGameStats(gameresult.bggid, gameresult.scores.length).then (gameStats)->

      gameresult = _.map gameresult.scores, (score) ->
        _.extend score, {y: score.score, name: score.player.name}

      # add highscore
      gameresult.push
        color: '#18BC9C'
        y: gameStats.highscore.score
        name: '<strong>Highscore</strong> (' + gameStats.highscore.player.name + ')'

      # add lowscore
      gameresult.push
        color: '#E74C3C'
        y: gameStats.lowscore.score
        name: '<strong>Lowscore</strong> (' + gameStats.lowscore.player.name + ')'

      # add average
      gameresult.push
        color: '#2C3E50'
        y: Math.round(gameStats.averageScore * 100) / 100
        name: '<strong>Average</strong>'

      gameresult = _.sortBy gameresult, (item) -> -item.y

      players = _.pluck gameresult, 'name'
      scores = _.map gameresult, (item) -> { y: item.y, color: item.color }

      #create chart
      $scope.gameresultChartConfig =
        options:
          chart:
            type: 'bar'
          title:
            text: ''
          subtitle:
            text: ''
          exporting:
            enabled: false
          credits:
            enabled: false
          yAxis:
            allowDecimals: false
            min: 0
            title:
              text: ''
          tooltip:
            valueSuffix: ' points'
          plotOptions:
            bar:
              gameresultLabels:
                enabled: true
        series: [ {
          pointWidth: 10,
          showInLegend: false,
          data: scores
        } ]
        title:
          text: ''
        xAxis:
          categories: players
          title:
            text: ''
        size:
          height: 230
          width: 500
      
      $scope.chartLoading = false

  
  showChart($scope.gameresult)
  $scope.$watch 'gameresult', showChart

