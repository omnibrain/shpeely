'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.games.game',
    url: '/:bggid'
    templateUrl: 'app/tournaments/tournament/games/game/game.html'
    controller: 'GameCtrl'
