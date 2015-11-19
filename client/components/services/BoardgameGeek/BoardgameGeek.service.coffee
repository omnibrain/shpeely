'use strict'

angular.module 'boardgametournamentApp'
.service 'BggApi', ($http)->

  BASE_URL = '/api/bgg'

  search: (query)->
    url = "#{BASE_URL}/search"
    params =
      query: query
    $http.get(url, {params: params})
      
  info: (bggid)->
    url = "#{BASE_URL}/info"
    params =
      bggid: bggid
    $http.get(url, {params: params})

