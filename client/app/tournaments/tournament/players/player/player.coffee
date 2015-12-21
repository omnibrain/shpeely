'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.players.player',
    url: '/:player'
    templateUrl: 'app/tournaments/tournament/players/player/player.html'
    controller: 'PlayerCtrl'
