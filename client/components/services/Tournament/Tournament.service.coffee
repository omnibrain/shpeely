'use strict'

angular.module 'boardgametournamentApp'
.service 'Tournament', ($state, $http, Auth, $q, $stateParams)->

  activeTournament = {}
  listeners = []

  deferred = $q.defer()
  ready = true

  tournaments = []

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

  load: (slug)->
    $q (resolve, reject)=>
      $http.get("/api/tournaments/#{slug}").then (res)=>
        @setActive res.data
        resolve()

  reload: loadTournaments

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

  # goes to the home of the active tournament
  goToHome: ()-> $state.go 'tournament', {name: activeTournament.name}

  onChange: (listener)-> listeners.push listener

  getScores: ->
    $q (resolve, reject)->
      $http.get("/api/scores/#{activeTournament._id}").then (res)->
        resolve res.data
      , reject

  getTimeSeries: ->
    $q (resolve, reject)->
      $http.get("/api/scores/timeseries/#{activeTournament._id}").then (res)->
        resolve res.data
      , reject

  getGameResults: (limit)->
    $q (resolve, reject)->
      params =
        params:
          limit: limit
      $http.get("/api/tournaments/#{activeTournament._id}/gameresults", params).then (res)->
        resolve res.data
      , reject

  getGameStats: (bggid, numPlayers)->
    $q (resolve, reject)->
      params =
        params:
          bggid: bggid
          numPlayers: numPlayers
      $http.get("/api/tournaments/#{activeTournament._id}/games", params).then (res)->
        resolve res.data
      , reject

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


