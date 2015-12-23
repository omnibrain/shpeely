'use strict'

angular.module 'boardgametournamentApp'
.directive 'message', ->
  templateUrl: 'components/directives/message/message.html'
  restrict: 'E'
  controller: 'MessageCtrl'
  scope:
    message: '='
