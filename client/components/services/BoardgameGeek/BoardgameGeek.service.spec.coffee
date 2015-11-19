'use strict'

describe 'Service: BoardgameGeek', ->

  # load the service's module
  beforeEach module 'boardgametournamentApp'

  # instantiate service
  BoardgameGeek = undefined
  beforeEach inject (_BoardgameGeek_) ->
    BoardgameGeek = _BoardgameGeek_

  it 'should do something', ->
    expect(!!BoardgameGeek).toBe true
