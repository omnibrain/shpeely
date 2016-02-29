'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'donate',
    url: '/donate'
    templateUrl: 'app/donate/donate.html'
    controller: 'DonateCtrl'
