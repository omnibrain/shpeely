'use strict'

angular.module 'boardgametournamentApp'
.controller 'TournamentCtrl', ($scope, $stateParams, BggApi, $timeout, Auth, $http, Tournament) ->

  DEFAUL_NUM_PLAYERS = 4

  $scope.newGameResult = {}
  $scope.newGameResult.scores = ({} for i in _.range(DEFAUL_NUM_PLAYERS))

  $scope.gameOptions = []
  $scope.selectedGame = null
  $scope.gameInfoLoading = false
  $scope.gameSearchLoading = false

  $scope.players = []
  $scope.canEdit = false
  $scope.emptyState = true

  loadTournament = (slug)->
    $http.get("/api/tournaments/#{slug}").then (res)->
      tournament = res.data
      $scope.tournament = tournament

      Tournament.setActive tournament
      $scope.players = _.sortBy tournament.members, 'name'

      Tournament.canEdit (canEdit)->
        $scope.canEdit = canEdit
      
      tournament

  loadLatestGameResults = ->
    Tournament.getGameResults(6).then (gameResults)->
      $scope.gameResults = gameResults
      gameResults

  loadGameStats = ->
    Tournament.getGameStats().then (gameStats)->
      $scope.gameStats = gameStats
      gameStats

  loadPlayerStats = ->
    Tournament.getPlayerStats().then (playerStats)->
      $scope.playerStats = playerStats
      playerStats

  loadScores = ->
    Tournament.getScores().then (scores)->
      $scope.scores = scores
      scores

  loadTimeSeries = ->
    Tournament.getTimeSeries().then (timeSeries)->
      $scope.timeSeries = timeSeries
      timeSeries

  # Run requestst in serie: Order these by priority, e.g. 
  # the data that is first visible should be on top. 
  # Some of the data loaded here is only required by 
  # child states of this state.
  loadData = ->
    loadTournament($stateParams.slug)
    loadScores()
    loadTimeSeries()
    loadLatestGameResults()
    loadGameStats()
    loadPlayerStats()

  loadData()

  # is called when a game was selected in the dropdown
  getBggInfo = (bggid)->

    $scope.gameInfoLoading = true
    if not bggid or bggid == ''
      return


    BggApi.info(bggid).then (res)->
      info = res.data

      $scope.selectedGame =
        id: info.id
        thumbnail: info.thumbnail
        name: _.find([].concat(info.name), (name)-> name?.type == 'primary').value
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

  $scope.resetForm = ()->
    $scope.newGameResult.scores = _.map($scope.newGameResult.scores, ->{})
    $scope.newGameResult.bggid = null

  $scope.saveGame = (form)->
    gameResult = angular.copy($scope.newGameResult)

    # remove "empty" scores
    _.remove(gameResult.scores, (score)-> !score.player)

    # add tournament id
    gameResult.tournament = $scope.tournament._id

    $http.post('/api/gameresults', gameResult).then (res)->
      $scope.resetForm()
      loadData()

  $scope.playerSelectizeConfig =
    maxItems: 1
    create: (input, callback)->
      player = _.find $scope.players, (player)-> player.name == input
      if player then player else {name: "#{input} (new player)", _id: input}
    labelField: 'name'
    searchField: 'name'
    valueField: '_id'

  $scope.gameSelectizeConfig =
    selectOnTab: true
    maxItems: 1
    valueField: 'id'
    labelField: 'name'
    searchField: 'name'
    onChange: getBggInfo
    render:
      option: render
      item: render
    load: (query, callback)->

      $scope.gameSearchLoading = true

      self = @
      BggApi.search(query).then (res)->

        # there's a bug in selectize where the loading class is not removed. 
        # This will remove it for sure
        $scope.gameSearchLoading = false

        if not res.data.length
          return
        options = []
        for game in res.data
          options.push
            id: game.id
            year: game.yearpublished?.value || 'unknown'
            name: game.name.value
        callback _.sortBy options, 'name'





