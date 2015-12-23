'use strict'

angular.module 'boardgametournamentApp'
.controller 'MessagesCtrl', ($scope, $http) ->
  
  getMessages = ->
    $http.get('/api/messages').then (res)->
      $scope.messages = res.data

  getMessages()
