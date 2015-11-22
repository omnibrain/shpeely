'use strict'

angular.module 'boardgametournamentApp'
.controller 'TimeChartCtrl', ($scope, Tournament, $timeout) ->

  $scope.chartLoading = true

  showHideAll = (show)->
    chart = $scope.timechartConfig.getHighcharts()
    _.each chart.series, (serie)->
      serie.setVisible show, false
    chart.redraw()

  $scope.showAll = ()-> showHideAll(true)
  $scope.hideAll = ()-> showHideAll(false)

  # get the scores
  Tournament.onChange ->
    Tournament.getTimeSeries().then (timeSeries)->
      $scope.chartLoading = false

      $scope.timechartConfig =
        options:
          chart:
            type: 'line'
          credits:
            enabled: false
          tooltip:
            headerFormat: '<b>{series.name}</b><br>'
            pointFormat: '{point.time:%e. %b}: {point.y:.0f}'
          exporting:
            enabled: false
          plotOptions:
            line:
              marker:
                enabled: false
        # higharts-ng options
        title: text: ''
        subtitle: text: ''
        xAxis:
          title:
            text: ''
        yAxis:
          title:
            text: 'Score'
        series: timeSeries
        func: (c)->
          $timeout (-> c.reflow()), 0
