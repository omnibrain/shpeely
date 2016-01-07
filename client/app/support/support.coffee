'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'support',
    url: '/support'
    templateUrl: 'app/support/support.html'
    controller: 'SupportCtrl'
