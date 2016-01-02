'use strict'

describe 'Filter: capitalize', ->

  # load the filter's module
  beforeEach module 'shpeelyApp'

  # initialize a new instance of the filter before each test
  capitalize = undefined
  beforeEach inject ($filter) ->
    capitalize = $filter 'capitalize'

  it 'should return the input prefixed with \'capitalize filter:\'', ->
    text = 'angularjs'
    expect(capitalize text).toBe 'capitalize filter: ' + text
