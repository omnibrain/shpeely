'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentCalloutCtrl', ($scope, Tournament, ngDialog, $http) ->

  Tournament.getOwnPlayer $scope.tournament._id, (player)->
    $scope.player = player
    $scope.role = player?.role

  $scope.deleteDialog = ->
    ngDialog.open
      template: 'deleteTournamentModal'
      className: 'dialog dialog-danger'
      scope: $scope

  $scope.disconnectDialog = ->
    ngDialog.open
      template: 'forgetTournamentModal'
      className: 'dialog dialog-danger'
      scope: $scope


  $scope.disconnect = ->
    $http.post("/api/players/disconnect", {player: $scope.player._id}).then ->
      $scope.role = null
      Tournament.reload()

