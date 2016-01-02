'use strict'

angular.module 'shpeelyApp'
.directive 'bgginfo', ->
  templateUrl: 'components/directives/bgginfo/bgginfo.html'
  restrict: 'E'
  scope:
    bgginfo: '='
  controller: 'BggInfoCtrl'

