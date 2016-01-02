'use strict'

angular.module 'shpeelyApp'
.directive 'scorechart', ->
  templateUrl: 'components/directives/scorechart/scorechart.html'
  restrict: 'EA'
  controller: 'ScoreChartCtrl'
  scope:
    scores: '='
