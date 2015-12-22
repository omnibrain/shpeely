'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.gameresults.gameresult',
    url: '/:gameresult'
    templateUrl: 'app/tournaments/tournament/gameresults/gameresult/gameresult.html'
    controller: 'GameresultCtrl'
