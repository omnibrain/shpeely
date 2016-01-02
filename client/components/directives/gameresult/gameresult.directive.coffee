'use strict'

angular.module 'shpeelyApp'
.directive 'gameresult', ->
  templateUrl: 'components/directives/gameresult/gameresult.html'
  restrict: 'E'
  controller: 'GameResultCtrl'
  scope:
    gameresult: '='
