'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament.gameresults',
    url: '/gameresults'
    templateUrl: 'app/tournament/gameresults/gameresults.html'
    controller: 'GameresultsCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
