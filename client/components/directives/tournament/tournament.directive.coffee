'use strict'

angular.module 'shpeelyApp'
.directive 'tournamentCallout', ->
  templateUrl: 'components/directives/tournament/tournament.html'
  restrict: 'EA'
  scope:
    tournament: '='
    onRemove: '&'
  controller: 'TournamentCalloutCtrl'
