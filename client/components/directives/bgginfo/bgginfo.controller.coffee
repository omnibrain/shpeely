'use strict'

angular.module 'boardgametournamentApp'
.controller 'BggInfoCtrl', ($scope) ->
  
  console.log $scope.bgginfo

  adaptData = (info)->
    if not info then return

    $scope.gameInfo =
      id: info.id
      thumbnail: info.thumbnail
      name: _.find([].concat(info.name), (name)-> name?.type == 'primary').value
      yearPublished: info.yearpublished.value
      statistics: info.statistics.ratings
      maxPlayers: info.maxplayers.value
      playTime: info.maxplaytime.value
      rank: _.find([].concat(info.statistics.ratings.ranks.rank), (rank)-> rank.name == 'boardgame').value
      tags: info.link

  $scope.$watch 'bgginfo', adaptData
  adaptData($scope.bgginfo)
