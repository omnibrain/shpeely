'use strict'

angular.module 'boardgametournamentApp'
.controller 'DashboardCtrl', ($scope, Tournament, $http) ->

  $scope.reverse = false
  $scope.columns = [
    {name: 'Player', sortKey: 'user.player.name'}
    {name: 'Role', sortKey: 'user.player.role'}
    {name: 'Name', sortKey: 'user.name'}
    {name: 'Email', sortKey: 'user.email'}
    {name: '', sortKey: '', unsortable: true}
  ]

  $scope.memberFilter = (value, index, array)-> !!value._user

  $scope.sort = (column)->
    if column.usortable then return
    $scope.activeColumn = column
    $scope.reverse = !$scope.reverse

  $scope.activeTournament = Tournament.getActive()

  getUsers = ->
    Tournament.getUsers().then (users)->
      connectedPlayers = _.filter $scope.activeTournament.members, (member)-> member._user
      console.log connectedPlayers
      $scope.users = _.map users, (user)->
        user.player = _.find connectedPlayers, (player)-> player._user == user._id
        return user

  getUsers()

  $scope.disconnect = (user)->
    $http.post("/api/players/disconnect", {player: user.player._id}).then ->
      _.remove $scope.users, (u)-> user._id == u._id

  $scope.promote = (user)->
    $http.post("/api/players/promote", {player: user.player._id}).then (player)->
      user.player.role = 'admin'

  $scope.demote = (user)->
    $http.post("/api/players/demote", {player: user.player._id}).then (player)->
      user.player.role = 'member'
