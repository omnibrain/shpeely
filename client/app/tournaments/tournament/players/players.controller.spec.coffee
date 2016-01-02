'use strict'

describe 'Controller: PlayersCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  PlayersCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    PlayersCtrl = $controller 'PlayersCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
