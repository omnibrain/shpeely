'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament',
    url: ':slug'
    templateUrl: 'app/tournaments/overview/overview.html'
    controller: 'OverviewCtrl'
    resolve:
      tournaments: (Tournament)-> Tournament.promise
