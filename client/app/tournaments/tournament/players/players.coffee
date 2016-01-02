'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments.tournament.players',
    url: '/players'
    templateUrl: 'app/tournaments/tournament/players/players.html'
    controller: 'PlayersCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
