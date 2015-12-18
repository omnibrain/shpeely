'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament.gameresults.gameresult',
    url: '/:gameresult'
    templateUrl: 'app/tournament/gameresults/gameresult/gameresult.html'
    controller: 'GameresultCtrl'
