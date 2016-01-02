'use strict'

angular.module 'shpeelyApp'
.controller 'NavbarCtrl', ($scope, $location, Auth, Tournament, Message) ->


  $scope.isCollapsed = true
  $scope.isLoggedIn = Auth.isLoggedIn
  $scope.isAdmin = Auth.isAdmin
  $scope.getCurrentUser = Auth.getCurrentUser

  getUnread = ->
    Auth.isLoggedInAsync (loggedIn)->
      if loggedIn
        Message.count (res)->
          $scope.unreadMessagesCount = res.unread
      else
        $scope.unread = 0

  getUnread()

  $scope.logout = ->
    Auth.logout()
    $location.path '/login'

  $scope.isActive = (route) ->
    route is $location.path()

  $scope.tournaments = Tournament.getAll()

  $scope.$watch Tournament.getAll, (newValue, oldValue)->
    $scope.tournaments = newValue

  $scope.getPlayer = Tournament.getPlayer
  $scope.activeTournament = Tournament.getActive
  $scope.getRole = ->
    Tournament.getPlayer()?.role


