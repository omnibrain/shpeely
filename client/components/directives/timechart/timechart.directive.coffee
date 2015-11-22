'use strict'

angular.module 'boardgametournamentApp'
.directive 'timechart', ->
  templateUrl: 'components/directives/timechart/timechart.html'
  restrict: 'EA'
  controller: 'TimeChartCtrl'
