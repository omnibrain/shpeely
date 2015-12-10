'use strict'

describe 'Controller: GamesCtrl', ->

  # load the controller's module
  beforeEach module 'boardgametournamentApp'
  GamesCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    GamesCtrl = $controller 'GamesCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
