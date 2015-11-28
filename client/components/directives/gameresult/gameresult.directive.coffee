'use strict'

angular.module 'boardgametournamentApp'
.directive 'gameresult', ->
  templateUrl: 'components/directives/gameresult/gameresult.html'
  restrict: 'E'
  controller: 'GameResultCtrl'
  scope:
    gameresult: '='
