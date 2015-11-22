'use strict'

describe 'Directive: scorechart', ->

  # load the directive's module and view
  beforeEach module 'boardgametournamentApp'
  beforeEach module 'components/directives/scorechart/scorechart.html'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<scorechart></scorechart>'
    element = $compile(element) scope
    scope.$apply()
    expect(element.text()).toBe 'this is the scorechart directive'

