'use strict'

describe 'Directive: timespanselect', ->

  # load the directive's module and view
  beforeEach module 'shpeelyApp'
  beforeEach module 'components/directives/timespanselect/timespanselect.html'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<timespanselect></timespanselect>'
    element = $compile(element) scope
    scope.$apply()
    expect(element.text()).toBe 'this is the timespanselect directive'

