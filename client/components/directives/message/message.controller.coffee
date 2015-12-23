'use strict'

angular.module 'boardgametournamentApp'
.controller 'MessageCtrl', ($scope, Message) ->

  $scope.acceptMembershipRequest = ->
    Message.acceptMembershipRequest {id: $scope.message._id}, (res)->
      console.log message
      $scope.message.replied = true
      $scope.message.accepted = true

  $scope.denyMembershipRequest = ->
    console.log "deny!"
    Message.denyMembershipRequest {id: $scope.message._id}, (res)->
      console.log "denied!"
      $scope.message.replied = true
      $scope.message.accepted = false
