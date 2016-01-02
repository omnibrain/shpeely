'use strict'

describe 'Controller: TournamentsCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  TournamentsCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    TournamentsCtrl = $controller 'TournamentsCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
