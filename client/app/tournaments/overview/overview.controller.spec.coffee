'use strict'

describe 'Controller: OverviewCtrl', ->

  # load the controller's module
  beforeEach module 'boardgametournamentApp'
  OverviewCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    OverviewCtrl = $controller 'OverviewCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
