'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'game',
    url: '/:bggid'
    templateUrl: 'app/tournament/games/game/game/game.html'
    controller: 'GameCtrl'
