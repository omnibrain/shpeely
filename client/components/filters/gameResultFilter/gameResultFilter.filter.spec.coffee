'use strict'

describe 'Filter: gameResultFilter', ->

  # load the filter's module
  beforeEach module 'boardgametournamentApp'

  # initialize a new instance of the filter before each test
  gameResultFilter = undefined
  beforeEach inject ($filter) ->
    gameResultFilter = $filter 'gameResultFilter'

  it 'should return the input prefixed with \'gameResultFilter filter:\'', ->
    text = 'angularjs'
    expect(gameResultFilter text).toBe 'gameResultFilter filter: ' + text
