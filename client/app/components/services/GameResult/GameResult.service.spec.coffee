'use strict'

describe 'Service: GameResult', ->

  # load the service's module
  beforeEach module 'boardgametournamentApp'

  # instantiate service
  GameResult = undefined
  beforeEach inject (_GameResult_) ->
    GameResult = _GameResult_

  it 'should do something', ->
    expect(!!GameResult).toBe true
