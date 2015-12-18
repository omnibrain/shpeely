'use strict'

angular.module 'boardgametournamentApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournament',
    url: '/{slug}'
    templateUrl: 'app/tournament/tournament.html'
    controller: 'TournamentCtrl'
    resolve:
      tournaments: (Tournament, $stateParams)->
        Tournament.load $stateParams.slug
