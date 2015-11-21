'use strict'

angular.module 'boardgametournamentApp'
.service 'Tournament', ($state, $http)->

  listeners = []
  activeTournament = {}

  tournaments = []

  $http.get('/api/tournaments/mine').success (res) ->
    tournaments = res

  setActive: (tournament)->
    activeTournament = tournament
    listener(tournament) for listener in listeners

  getActive: ()-> activeTournament

  getAll: ()-> tournaments

  # goes to the home of the active tournament
  goToHome: ()-> $state.go 'tournamentoverview', {name: activeTournament.name}


  onChange: (listener)-> listeners.push listener

  

