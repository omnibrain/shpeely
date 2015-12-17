'use strict'

describe 'Controller: GameresultsCtrl', ->

  # load the controller's module
  beforeEach module 'boardgametournamentApp'
  GameresultsCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    GameresultsCtrl = $controller 'GameresultsCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
