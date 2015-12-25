'use strict'

angular.module 'boardgametournamentApp'
.controller 'NavbarCtrl', ($scope, $location, Auth, Tournament, Message) ->


  $scope.isCollapsed = true
  $scope.isLoggedIn = Auth.isLoggedIn
  $scope.isAdmin = Auth.isAdmin
  $scope.getCurrentUser = Auth.getCurrentUser

  $scope.getUnread = ->
    Auth.isLoggedInAsync (loggedIn)->
      if loggedIn
        Message.count (res)->
          $scope.unreadMessagesCount = res.unread
      else
        $scope.unread = 0

  $scope.logout = ->
    Auth.logout()
    $location.path '/login'

  $scope.isActive = (route) ->
    route is $location.path()

  $scope.tournaments = Tournament.getAll()

  $scope.$watch Tournament.getAll, (newValue, oldValue)->
    $scope.tournaments = newValue

  $scope.activeTournament = Tournament.getActive


