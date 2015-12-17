'use strict'

describe 'Directive: bgginfo', ->

  # load the directive's module and view
  beforeEach module 'boardgametournamentApp'
  beforeEach module 'components/bgginfo/bgginfo.html'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<bgginfo></bgginfo>'
    element = $compile(element) scope
    scope.$apply()
    expect(element.text()).toBe 'this is the bgginfo directive'

