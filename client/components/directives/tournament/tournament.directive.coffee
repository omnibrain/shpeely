'use strict'

angular.module 'boardgametournamentApp'
.directive 'tournamentCallout', ->
  templateUrl: 'components/directives/tournament/tournament.html'
  restrict: 'EA'
  scope:
    tournament: '='
    onRemove: '&'
  controller: 'TournamentCalloutCtrl'
