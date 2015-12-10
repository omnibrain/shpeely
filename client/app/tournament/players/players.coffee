'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament.players',
    url: '/players'
    templateUrl: 'app/tournament/players/players.html'
    controller: 'PlayersCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
