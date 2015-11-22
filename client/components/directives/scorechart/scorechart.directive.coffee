'use strict'

angular.module 'boardgametournamentApp'
.directive 'scorechart', ->
  templateUrl: 'components/directives/scorechart/scorechart.html'
  restrict: 'EA'
  controller: 'ScoreChartCtrl'
