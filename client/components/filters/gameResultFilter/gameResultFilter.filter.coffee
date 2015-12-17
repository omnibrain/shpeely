'use strict'

angular.module 'boardgametournamentApp'
.filter 'gameResultFilter', ->
  (gameResults, search) ->

    result = gameResults

    # filter game 
    if search.game and search.game.length
      result = _.filter result, (gameResult)->
        gameResult.game.name.toLowerCase().indexOf(search.game.toLowerCase()) > -1

    if search.numberOfPlayers and !isNaN(search.numberOfPlayers)
      result = _.filter result, (gameResult)->
        gameResult.scores.length == Number(search.numberOfPlayers)

    # filter player
    if search.player and search.player.length
      result = _.filter result, (gameResult)->
        found = _.find gameResult.scores, (score)->
          score.player.name.toLowerCase().indexOf(search.player.toLowerCase()) > -1
        !!found

    return result
