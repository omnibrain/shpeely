'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentCalloutCtrl', ($scope, Tournament, ngDialog) ->

  Tournament.getOwnPlayer $scope.tournament._id, (player)->
    $scope.role = player?.role

  $scope.delete = ()->
    ngDialog.open
      template: 'deleteTournamentModal'
      className: 'dialog dialog-danger'
      scope: $scope
