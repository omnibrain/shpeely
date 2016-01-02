'use strict'

angular.module 'shpeelyApp'
.directive 'gamelink', ->
  templateUrl: 'components/directives/gamelink/gamelink.html'
  restrict: 'E'
  controller: 'GamelinkCtrl'
  scope:
    bggid: '='
    name: '='
