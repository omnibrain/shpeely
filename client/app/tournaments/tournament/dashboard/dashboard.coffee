'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.dashboard',
    url: '/dashboard'
    templateUrl: 'app/tournaments/tournament/dashboard/dashboard.html'
    controller: 'DashboardCtrl'
