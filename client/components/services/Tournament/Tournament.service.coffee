'use strict'

angular.module 'boardgametournamentApp'
.service 'Tournament', ($state, $http, Auth, $q)->

  activeTournament = {}
  listeners = []

  # is resolved as soon as the 
  # active tournament is set
  deferred = $q.defer()

  tournaments = []

  loadTournaments = ->
    Auth.isLoggedInAsync()?.then ->
      $http.get('/api/tournaments/mine').success (res) ->
        tournaments = res

  loadTournaments()

  reload: loadTournaments

  setActive: (tournament)->
    activeTournament = tournament
    listener(tournament) for listener in listeners
    deferred.resolve tournament

  getActive: ()->
    if Auth.isLoggedIn()
      activeTournament
    else
      activeTournament = {}

  getActiveAsync: ()-> deferred.promise

  getAll: ()-> tournaments

  # goes to the home of the active tournament
  goToHome: ()-> $state.go 'tournamentoverview', {name: activeTournament.name}

  onChange: (listener)-> listeners.push listener

  getScores: ->
    self = @
    $q (resolve, reject)->
      self.getActiveAsync().then (tournament)->
        $http.get("/api/scores/#{tournament._id}").then (res)->
          resolve res.data
        , reject
       
    

