'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.players.player',
    url: '/:player'
    templateUrl: 'app/tournaments/tournament/players/player/player.html'
    controller: 'PlayerCtrl'
