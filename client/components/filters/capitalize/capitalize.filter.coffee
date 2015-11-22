'use strict'

angular.module 'boardgametournamentApp'
.filter 'capitalize', ->
  (input) ->
    if input then input.charAt(0).toUpperCase() + input.slice(1) else ''
