'use strict'

angular.module 'boardgametournamentApp'
.service 'Tournament', ($state, $http, Auth)->

  listeners = []
  activeTournament = {}

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

  getActive: ()->
    if Auth.isLoggedIn()
      activeTournament
    else
      activeTournament = {}

  getAll: ()-> tournaments

  # goes to the home of the active tournament
  goToHome: ()-> $state.go 'tournamentoverview', {name: activeTournament.name}


  onChange: (listener)-> listeners.push listener

  

