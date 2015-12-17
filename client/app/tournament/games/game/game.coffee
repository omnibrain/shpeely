'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament.games.game',
    url: '/:bggid'
    templateUrl: 'app/tournament/games/game/game.html'
    controller: 'GameCtrl'
