'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.games',
    url: '/games'
    templateUrl: 'app/tournaments/tournament/games/games.html'
    controller: 'GamesCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
