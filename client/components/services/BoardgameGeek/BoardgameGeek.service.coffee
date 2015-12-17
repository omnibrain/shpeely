'use strict'

angular.module 'boardgametournamentApp'
.service 'BggApi', ($http, $q)->

  BASE_URL = '/api/bgg'

  request = (url, params={})->
    params =
      params: params
      cache: true
    $q (resolve, reject)->
      $http.get("#{BASE_URL}#{url}", params).then (res)->
        resolve res.data
      , reject

  search: (query)->
    request  "/search", {query: query}
      
  info: (bggid)->
    $q (resolve, reject)->
      request("/info", {bggid: bggid}).then (info)->
        resolve
          id: info.id
          thumbnail: info.thumbnail
          name: _.find([].concat(info.name), (name)-> name?.type == 'primary').value
          yearPublished: info.yearpublished.value
          statistics: info.statistics.ratings
          maxPlayers: info.maxplayers.value
          playTime: info.maxplaytime.value
          rank: _.find([].concat(info.statistics.ratings.ranks.rank), (rank)-> rank.name == 'boardgame').value
          tags: info.link
      , reject

