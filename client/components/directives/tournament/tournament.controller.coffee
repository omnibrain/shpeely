'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentCalloutCtrl', ($scope, Tournament) ->

  Tournament.getOwnPlayer $scope.tournament._id, (player)->
    $scope.role = player?.role

