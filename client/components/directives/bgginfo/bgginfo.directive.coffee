'use strict'

angular.module 'boardgametournamentApp'
.directive 'bgginfo', ->
  templateUrl: 'components/directives/bgginfo/bgginfo.html'
  restrict: 'E'
  scope:
    bgginfo: '='
  controller: 'BggInfoCtrl'

