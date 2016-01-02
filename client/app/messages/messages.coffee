'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'messages',
    url: '/messages'
    templateUrl: 'app/messages/messages.html'
    controller: 'MessagesCtrl'
