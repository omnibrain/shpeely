'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments',
    url: '/tournaments'
    templateUrl: 'app/tournaments/tournaments.html'
    controller: 'TournamentsCtrl'
    authenticate: true
