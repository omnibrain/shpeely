'use strict'

describe 'Controller: TournamentCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  TournamentCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    TournamentCtrl = $controller 'TournamentCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
