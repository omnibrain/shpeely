'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'messages',
    url: '/messages'
    templateUrl: 'app/messages/messages.html'
    controller: 'MessagesCtrl'
