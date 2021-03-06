'use strict'

angular.module 'shpeelyApp'
.service 'Tournament', ($state, $http, Auth, $q, $stateParams)->

  activeTournament = null

  deferred = $q.defer()
  cached = true

  tournaments = []
  cached = false

  request = (url, params = {}, method = 'GET')->
    $q (resolve, reject)->
      config =
        params: params
        url: url
        method: method
        cache: cached
      $http(config).then (res)->
        resolve res.data
      , reject

  loadTournaments = ->
    Auth.isLoggedInAsync (loggedIn)->
      if loggedIn
        request('/api/tournaments/mine').then (_tournaments)->
          tournaments = _tournaments
          deferred.resolve tournaments
      else
        request('api/tournaments', {limit: 18}).then (_tournaments)->
          tournaments = _tournaments
          deferred.resolve tournaments

  loadTournaments()

  load: (slug)->
    $q (resolve, reject)=>
      request("/api/tournaments/#{slug}").then (tournament)=>
        @setActive tournament
        resolve()

  getTournaments: (query, limit=18)->
    request '/api/tournaments',
      query: query
      limit: limit

  search: (query)->
    request "/api/tournaments/search/#{query}"

  reload: loadTournaments

  cache: (cache)-> cached = cache

  promise: deferred.promise

  add: (tournament)->
    tournaments.push tournament

  delete: (tournament)->
    if !tournament and !activeTournament then return

    id = if !tournament and activeTournament then activeTournament._id else tournament._id

    $q (resolve, reject)->
      request("/api/tournaments/#{id}", {}, 'DELETE').then ->
        _.remove tournaments, (t)-> t._id == id
        resolve()
      , reject



  setActive: (tournament)-> activeTournament = tournament

  getActive: ()->
    activeTournament

  getAll: -> tournaments

  getUsers: ->
    request "/api/tournaments/#{activeTournament._id}/users"

  getScores: (player)->
    request "/api/scores/#{activeTournament._id}"

  getTimeSeries: ->
    request "/api/scores/timeseries/#{activeTournament._id}"

  getGameResults: (limit)->
    request "/api/tournaments/#{activeTournament._id}/gameresults",
      limit: limit

  getGameStats: (bggid, numPlayers)->
    request "/api/tournaments/#{activeTournament._id}/games",
      bggid: bggid
      numPlayers: numPlayers

  getPlayerStats: (params = {})->
    request "/api/tournaments/#{activeTournament._id}/players", params

  getGamePlayerStats: (params = {})->
    request "/api/tournaments/#{activeTournament._id}/gamePlayerStats", params

  getOwnActivePlayer: (callback)->
    if not activeTournament
      console.error "No active tournament"
    else
      @getOwnPlayer activeTournament._id, callback

  # returns the own player of the currently logged in user
  getOwnPlayer: (tournamentId, callback)->
    @promise.then =>
      Auth.isLoggedInAsync (loggedIn)=>
        if loggedIn
          tournament = _.find(tournaments, (tournament)-> tournament._id == tournamentId)
          if not tournament then return callback()
          player = _.find(tournament.members, (member)->
            member._user and member._user == Auth.getCurrentUser()._id)
          callback player
        else
          callback()

  getPlayer: ->
    if not activeTournament then return
    player = _.find(activeTournament.members, (member)->
      member._user and member._user == Auth.getCurrentUser()._id)

  canEdit: (callback)->
    @getOwnActivePlayer (player)->
      if player then callback player.role in ['member', 'admin'] else callback(false)


