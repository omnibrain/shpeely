'use strict'

angular.module 'boardgametournamentApp'
.controller 'MessagesCtrl', ($scope, $http, Message, $timeout) ->

  getMessages = ->
    Message.query (messages)->
      $scope.unreadMessages = _.filter messages, (msg)-> !msg.read
      $scope.readMessages = _.filter messages, (msg)-> msg.read
      
      # mark messages as read after a short delay
      $timeout ->
        _.chain(angular.copy messages)
          .filter (msg)-> !msg.read
          .each (msg, i)->
            msg.read = true
            msg.$save()
      , 3000


  getMessages()
