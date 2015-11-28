'use strict'

angular.module 'boardgametournamentApp'
.controller 'ScoreChartCtrl', ($scope, Tournament, $timeout) ->

  $scope.chartLoading = true

  # get the scores
  Tournament.onChange ->
    Tournament.getScores().then (scores)->

      $scope.chartLoading = false

      data = _.chain scores
        .pluck 'score'
        .map (score) -> {color: (if score < 0 then '#E74C3C' else '#18BC9C'), y: score}
        .value()

      players = _.pluck(scores, 'player')

      $scope.scorechartConfig =
        options:
          chart:
            type: 'column'
          exporting:
            enabled: false
          credits:
            enabled: false
        # higharts-ng options
        title:
          text: ''
        series: [ {
          name: 'Score'
          showInLegend: false
          data: data
        } ]
        xAxis:
          categories: _.chain(scores).pluck('player').pluck('name').value()
        yAxis:
          title:
            text: 'Score'
        func: (c)->
          $timeout (-> c.reflow()), 0

