'use strict'

describe 'Controller: SupportCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  SupportCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    SupportCtrl = $controller 'SupportCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
