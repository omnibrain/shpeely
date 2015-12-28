'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.gameresults.gameresult.edit',
    url: '/edit'
    templateUrl: 'app/tournaments/tournament/gameresults/gameresult/edit/edit.html'
    controller: 'GameResultEditCtrl'
