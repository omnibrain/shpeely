'use strict'

angular.module 'boardgametournamentApp'
.controller 'OverviewCtrl', ($scope, $stateParams, BggApi, $timeout) ->

  BGG_SEARCH_URL = 'https://boardgamegeek.com/xmlapi2/search'
  DEFAUL_NUM_PLAYERS = 4

  $scope.newGameResult = []
  $scope.tournamentName = $stateParams.name

  $scope.newGameResult.push {} for i in _.range(DEFAUL_NUM_PLAYERS)

  $scope.gameOptions = []
  $scope.selectedGame = null

  # is called when a game was selected in the dropdown
  getBggInfo = (bggid)->
    if not bggid or bggid == ''
      return
    BggApi.info(bggid).then (res)->
      info = res.data
      console.log info
      $scope.selectedGame =
        thumbnail: info.thumbnail
        name: _.find([].concat(info.name), (name)-> name.type == 'primary').value
        yearPublished: info.yearpublished.value
        statistics: info.statistics.ratings
        maxPlayers: info.maxplayers.value

      # add or remove score rows
      numPlayersDelta = $scope.newGameResult.length - info.maxplayers.value
      console.log numPlayersDelta
      if numPlayersDelta < 0
        $scope.newGameResult.push {} for i in _.range(0, -numPlayersDelta)
      else if numPlayersDelta > 0
        $scope.newGameResult = $scope.newGameResult[0...info.maxplayers.value]

  render = (data, escape)->
    "<div>#{escape data.name}<span class='year'>(#{escape data.year})</span></div>"

  $scope.selectizeConfig =
    maxItems: 1
    valueField: 'id'
    labelField: 'name'
    searchField: 'name'
    onChange: getBggInfo
    render:
      option: render
      item: render
    load: (query, callback)->
      self = @
      BggApi.search(query).then (res)->
        if not res.data.length
          return
        options = []
        for game in res.data
          options.push
            id: game.id
            year: game.yearpublished.value
            name: game.name.value
        callback options





