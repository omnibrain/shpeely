'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament',
    url: '/:slug'
    templateUrl: 'app/tournaments/tournament/tournament.html'
    controller: 'TournamentCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
