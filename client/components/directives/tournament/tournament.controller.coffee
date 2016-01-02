'use strict'

angular.module 'shpeelyApp'
.controller 'TournamentCalloutCtrl', ($scope, Tournament, ngDialog, $http, Auth) ->

  $scope.claimablePlayers = _.filter $scope.tournament.members, (member)-> !member._user

  Tournament.getOwnPlayer $scope.tournament._id, (player)->
    $scope.player = player
    $scope.role = player?.role

  Auth.isLoggedInAsync (loggedIn)->
    $scope.loggedIn = loggedIn

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

  $scope.connectDialog = ->
    ngDialog.open
      template: 'connectToTournamentModal'
      className: 'dialog dialog-primary'
      scope: $scope

  $scope.disconnect = ->
    $http.post("/api/players/disconnect", {player: $scope.player._id}).then ->
      $scope.role = null
      Tournament.reload()

  $scope.claimPlayer = (player)->
    if not player then return
    $http.post("/api/messages/claimPlayer", {player: player}).then ->
      console.log "request sent!"

  $scope.memberSelectizeConfig =
    maxItems: 1
    valueField: '_id'
    labelField: 'name'
    delimiter: '|'
    placeholder: 'Select Your Player...'

