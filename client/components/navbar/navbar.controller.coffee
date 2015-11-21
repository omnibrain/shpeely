'use strict'

angular.module 'boardgametournamentApp'
.controller 'NavbarCtrl', ($scope, $location, Auth, Tournament) ->
  $scope.menu = [
    #{title: 'Tournaments', state: 'tournaments'},
  ]
  $scope.isCollapsed = true
  $scope.isLoggedIn = Auth.isLoggedIn
  $scope.isAdmin = Auth.isAdmin
  $scope.getCurrentUser = Auth.getCurrentUser

  $scope.logout = ->
    Auth.logout()
    $location.path '/login'

  $scope.isActive = (route) ->
    route is $location.path()

  $scope.tournaments = Tournament
