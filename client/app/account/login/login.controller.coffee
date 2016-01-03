'use strict'

angular.module 'shpeelyApp'
.controller 'LoginCtrl', ($scope, Auth, $location, $state, $window, Tournament) ->
  $scope.user = {}
  $scope.errors = {}
  $scope.login = (form) ->
    $scope.submitted = true

    if form.$valid
      # Logged in, redirect to home
      Auth.login
        email: $scope.user.email
        password: $scope.user.password

      .then ->
        Tournament.reload()
        $state.go 'tournaments'

      .catch (err) ->
        $scope.errors.other = err.message

  $scope.loginOauth = (provider) ->
    $window.location.href = '/auth/' + provider
