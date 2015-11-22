'use strict'

describe 'Directive: tournament', ->

  # load the directive's module and view
  beforeEach module 'boardgametournamentApp'
  beforeEach module 'components/directives/tournament/tournament.html'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<tournament></tournament>'
    element = $compile(element) scope
    scope.$apply()
    expect(element.text()).toBe 'this is the tournament directive'

