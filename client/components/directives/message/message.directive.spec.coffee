'use strict'

describe 'Directive: message', ->

  # load the directive's module and view
  beforeEach module 'boardgametournamentApp'
  beforeEach module 'components/directives/message/message.html'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<message></message>'
    element = $compile(element) scope
    scope.$apply()
    expect(element.text()).toBe 'this is the message directive'

