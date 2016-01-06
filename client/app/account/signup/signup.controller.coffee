'use strict'

angular.module 'shpeelyApp'
.controller 'SignupCtrl', ($scope, Auth, $location, $state, $window, config) ->

  $scope.recaptchaResponse = null
  $scope.user = {}
  $scope.errors = {}
  $scope.register = (form) ->
    $scope.submitted = true

    if (not $scope.recaptchaResponse) and config.recaptchaSitekey
      $scope.recaptchaError = true
      return

    if form.$valid
      # Account created, redirect to home
      Auth.createUser
        name: $scope.user.name
        email: $scope.user.email
        password: $scope.user.password
        recaptcha: $scope.recaptchaResponse

      .then ->
        $state.go 'tournaments'

      .catch (err) ->
        err = err.data
        $scope.errors = {}

        # Update validity of form fields that match the mongoose errors
        angular.forEach err.errors, (error, field) ->
          form[field].$setValidity 'mongoose', false
          $scope.errors[field] = error.message

  $scope.loginOauth = (provider) ->
    $window.location.href = '/auth/' + provider

  # recaptcha stuff
  renderRecaptcha = ->
    if not config.recaptchaSitekey
      return
    widgetId = grecaptcha.render  'signup-recaptcha',
      sitekey: config.recaptchaSitekey
      callback: ->
        $scope.recaptchaResponse = grecaptcha.getResponse(widgetId)


  if not $window.recaptchaReady
    $window.onRecaptchaReady = renderRecaptcha
  else
    renderRecaptcha()
