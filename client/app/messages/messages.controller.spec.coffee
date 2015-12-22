'use strict'

describe 'Controller: MessagesCtrl', ->

  # load the controller's module
  beforeEach module 'boardgametournamentApp'
  MessagesCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    MessagesCtrl = $controller 'MessagesCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
