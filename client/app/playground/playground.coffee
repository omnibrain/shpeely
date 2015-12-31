'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'playground',
    url: '/playground'
    templateUrl: 'app/playground/playground.html'
    controller: 'PlaygroundCtrl'
