'use strict'

angular.module 'shpeelyApp'
.filter 'gameResultFilter', ->
  (gameResults, search) ->

    result = gameResults

    # filter game 
    if search.game and search.game.length
      result = _.filter result, (gameResult)->
        gameResult.game.name == search.game

    if search.numberOfPlayers and !isNaN(search.numberOfPlayers)
      result = _.filter result, (gameResult)->
        gameResult.scores.length == Number(search.numberOfPlayers)

    # filter player
    if search.players and search.players.length
      result = _.filter result, (gameResult)->
        players = _.map gameResult.scores, 'player.name'
        (_.intersection players, search.players).length == search.players.length

    return result
