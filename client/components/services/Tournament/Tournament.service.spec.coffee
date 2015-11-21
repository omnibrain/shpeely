'use strict'

describe 'Service: ActiveTournament', ->

  # load the service's module
  beforeEach module 'boardgametournamentApp'

  # instantiate service
  ActiveTournament = undefined
  beforeEach inject (_ActiveTournament_) ->
    ActiveTournament = _ActiveTournament_

  it 'should do something', ->
    expect(!!ActiveTournament).toBe true
