'use strict'

angular.module 'shpeelyApp'
.directive 'playerlink', ->
  templateUrl: 'components/directives/playerlink/playerlink.html'
  restrict: 'E'
  controller: 'PlayerlinkCtrl'
  scope:
    player: '='
    tournament: '='
