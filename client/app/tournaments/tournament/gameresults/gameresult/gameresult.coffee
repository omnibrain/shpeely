'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.gameresults.gameresult',
    url: '/:gameresult'
    templateUrl: 'app/tournaments/tournament/gameresults/gameresult/gameresult.html'
    controller: 'GameresultCtrl'
