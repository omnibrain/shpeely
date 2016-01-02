'use strict'

describe 'Controller: PlaygroundCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  PlaygroundCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    PlaygroundCtrl = $controller 'PlaygroundCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
