'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.gameresults',
    url: '/gameresults'
    templateUrl: 'app/tournaments/tournament/gameresults/gameresults.html'
    controller: 'GameresultsCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
