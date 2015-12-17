'use strict'

angular.module 'boardgametournamentApp'
.service 'Tournament', ($state, $http, Auth, $q, $stateParams)->

  activeTournament = {}
  listeners = []

  deferred = $q.defer()
  ready = true

  tournaments = []
  cached = false

  loadTournaments = ->
    Auth.isLoggedInAsync (loggedIn)->
      if loggedIn
        $http.get('/api/tournaments/mine').success (res) ->
          tournaments = res
          deferred.resolve tournaments
      else
        $http.get('/api/tournaments').success (res) ->
          tournaments = res
          deferred.resolve tournaments

  loadTournaments()

  request = (url, params = {})->
    $q (resolve, reject)->
      params = _.extend params,
        cache: cached
      $http.get(url, params).then (res)->
        resolve res.data
      , reject

  load: (slug)->
    $q (resolve, reject)=>
      request("/api/tournaments/#{slug}").then (tournament)=>
        @setActive tournament
        resolve()

  reload: loadTournaments

  cache: (cache)-> cached = cache

  isReady: -> ready
  promise: deferred.promise

  add: (tournament)->
    tournaments.push tournament

  setActive: (tournament)->
    activeTournament = tournament
    listener(tournament) for listener in listeners

  getActive: ()->
    activeTournament

  getAll: -> tournaments

  getAllAsync: (callback)->
    if ready then callback(tournaments) else deferred.promise.then(callback)

  getScores: (player)->
    request "/api/scores/#{activeTournament._id}"

  getTimeSeries: ->
    request "/api/scores/timeseries/#{activeTournament._id}"

  getGameResults: (limit)->
    request "/api/tournaments/#{activeTournament._id}/gameresults",
      params:
        limit: limit

  getGameStats: (bggid, numPlayers)->
    request "/api/tournaments/#{activeTournament._id}/games",
      params:
        bggid: bggid
        numPlayers: numPlayers

  getPlayerStats: (params = {})->
    request "/api/tournaments/#{activeTournament._id}/players",
      params: params

  getGamePlayerStats: (params = {})->
    request "/api/tournaments/#{activeTournament._id}/gamePlayerStats",
      params: params

  getOwnActivePlayer: (callback)->
    if not activeTournament
      console.error "No active tournament"
    else
      @getOwnPlayer activeTournament._id, callback

  # returns the own player of the currently logged in user
  getOwnPlayer: (tournamentId, callback)->
    Auth.isLoggedInAsync (loggedIn)=>
      if loggedIn
        tournament = _.find(tournaments, (tournament)-> tournament._id == tournamentId)
        player = _.find(tournament.members, (member)-> member._user == Auth.getCurrentUser()._id)
        callback player
      else
        callback()

  canEdit: (callback)->
    @getOwnActivePlayer (player)->
      if player then callback player.role in ['editor', 'admin'] else callback(false)


