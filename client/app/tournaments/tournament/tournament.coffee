'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament',
    url: '/:slug'
    templateUrl: 'app/tournaments/tournament/tournament.html'
    controller: 'TournamentCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
