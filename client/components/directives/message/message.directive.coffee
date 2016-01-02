'use strict'

angular.module 'shpeelyApp'
.directive 'message', ->
  templateUrl: 'components/directives/message/message.html'
  restrict: 'E'
  controller: 'MessageCtrl'
  scope:
    message: '='
