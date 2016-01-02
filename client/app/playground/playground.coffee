'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'playground',
    url: '/playground'
    templateUrl: 'app/playground/playground.html'
    controller: 'PlaygroundCtrl'
