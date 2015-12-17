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
    request  "/info", {bggid: bggid}

