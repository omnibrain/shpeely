'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournamentoverview',
    url: '/tournaments/:name'
    templateUrl: 'app/tournaments/overview/overview.html'
    controller: 'OverviewCtrl'
