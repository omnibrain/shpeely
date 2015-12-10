'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament.games',
    url: '/games'
    templateUrl: 'app/tournament/games/games.html'
    controller: 'GamesCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
