'use strict'

describe 'Controller: GameresultCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  GameresultCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    GameresultCtrl = $controller 'GameresultCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
