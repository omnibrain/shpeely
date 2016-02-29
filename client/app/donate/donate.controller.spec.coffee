'use strict'

describe 'Controller: DonateCtrl', ->

  # load the controller's module
  beforeEach module 'shpeelyApp'
  DonateCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DonateCtrl = $controller 'DonateCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
