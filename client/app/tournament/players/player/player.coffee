'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament.players.player',
    url: '/:player'
    templateUrl: 'app/tournament/players/player/player.html'
    controller: 'PlayerCtrl'
