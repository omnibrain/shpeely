'use strict'

describe 'Service: Message', ->

  # load the service's module
  beforeEach module 'boardgametournamentApp'

  # instantiate service
  Message = undefined
  beforeEach inject (_Message_) ->
    Message = _Message_

  it 'should do something', ->
    expect(!!Message).toBe true
