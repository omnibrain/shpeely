'use strict'

describe 'Service: Player', ->

  # load the service's module
  beforeEach module 'boardgametournamentApp'

  # instantiate service
  Player = undefined
  beforeEach inject (_Player_) ->
    Player = _Player_

  it 'should do something', ->
    expect(!!Player).toBe true
