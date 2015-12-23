'use strict'

angular.module 'boardgametournamentApp'
.directive 'playerlink', ->
  templateUrl: 'components/directives/playerlink/playerlink.html'
  restrict: 'E'
  controller: 'PlayerlinkCtrl'
  scope:
    player: '='
    tournament: '='
