'use strict'

angular.module 'shpeelyApp'
.directive 'timechart', ->
  templateUrl: 'components/directives/timechart/timechart.html'
  restrict: 'EA'
  controller: 'TimeChartCtrl'
  scope:
    timeSeries: '='
