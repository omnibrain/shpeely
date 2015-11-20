'use strict'

angular.module 'boardgametournamentApp'
.controller 'OverviewCtrl', ($scope, $stateParams, BggApi, $timeout, Auth) ->

  DEFAUL_NUM_PLAYERS = 4

  # load the tournament from the server
  $http.get('/api/tournaments/mine', {name: $stateParams.name}).then (res)->
    console.log "tournament: ", res.data
    $scope.newGameResult.tournament = res.data[0]

  $scope.newGameResult.scores = ({} for i in _.range(DEFAUL_NUM_PLAYERS))

  $scope.gameOptions = []
  $scope.selectedGame = null
  $scope.gameInfoLoading = false

  $scope.players = [Auth.getCurrentUser()]
  console.log $scope.players

  # is called when a game was selected in the dropdown
  getBggInfo = (bggid)->
    $scope.gameInfoLoading = true
    if not bggid or bggid == ''
      return
    BggApi.info(bggid).then (res)->
      info = res.data
      console.log info
      $scope.selectedGame =
        id: info.id
        thumbnail: info.thumbnail
        name: _.find([].concat(info.name), (name)-> name.type == 'primary').value
        yearPublished: info.yearpublished.value
        statistics: info.statistics.ratings
        maxPlayers: info.maxplayers.value
        playTime: info.maxplaytime.value
        rank: _.find([].concat(info.statistics.ratings.ranks.rank), (rank)-> rank.name == 'boardgame').value
        tags: info.link

      # add or remove score rows
      numPlayersDelta = $scope.newGameResult.scores.length - info.maxplayers.value
      if numPlayersDelta < 0
        $scope.newGameResult.scores.push {} for i in _.range(0, -numPlayersDelta)
      else if numPlayersDelta > 0
        $scope.newGameResult.scores = $scope.newGameResult.scores[0...info.maxplayers.value]

      $scope.gameInfoLoading = false

  render = (data, escape)->
    "<div>#{escape data.name}<span class='year'>(#{escape data.year})</span></div>"

  $scope.saveGame = (form)->
    $http.post('/api/gameresult', $scope.newGameResult).then (res)->
      console.log "Game result saved!"

  $scope.playerSelectizeConfig =
    maxItems: 1
    create: true
    labelField: 'name'
    searchField: 'name'
    valueField: '_id'

  $scope.gameSelectizeConfig =
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
            year: game.yearpublished?.value || 'unknown'
            name: game.name.value
        callback options





