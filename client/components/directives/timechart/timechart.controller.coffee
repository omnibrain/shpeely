'use strict'

angular.module 'shpeelyApp'
.controller 'TimeChartCtrl', ($scope, $timeout, $http, $sanitize, $state, $window) ->

  $scope.chartLoading = true

  $scope.timeChartStyle =
    width: $window.innerWidth - 50 + 'px'
    display: 'none'

  showHideAll = (show)->
    chart = $scope.timechartConfig.getHighcharts()
    _.each chart.series, (serie)->
      serie.setVisible show, false
    chart.redraw()

  $scope.showAll = -> showHideAll(true)
  $scope.hideAll = -> showHideAll(false)

  # FOR TESTING
  $scope.fromTime = new Date('2015/6')

  createChart = (timeSeries)->

    if not timeSeries then return

    console.log timeSeries.meta

    if $scope.fromTime
      firstIndex = _.findIndex timeSeries.meta, (result, i)->
        result.time > $scope.fromTime.getTime()
      reverseIndex = timeSeries.meta.length - firstIndex

      # start from firstIndex - 1 and subtract score from firstIndex -1
      console.log new Date(timeSeries.meta[firstIndex - 1].time)
      console.log new Date(timeSeries.meta[firstIndex].time)
      console.log new Date(timeSeries.meta[firstIndex + 1].time)

      console.log "reverse index:", reverseIndex
      console.log "first index", firstIndex

      # transform the scores of each serie
      _.each timeSeries.series, (serie)->

        # cut all data before fromTime
        subtract = 0
        if serie.data.length > reverseIndex
          resetIndex = (serie.data.length - reverseIndex) - 1
          subtract = serie.data[resetIndex].y
          serie.data = _.takeRight serie.data, reverseIndex
        # adapt the data
        _.each serie.data, (point)->
          point.y = point.y - subtract

        # drop the 0 points
        serie.data = _.dropWhile serie.data, ['y', 0]

      console.log timeSeries.series
      

    $scope.timechartConfig =
      options:
        chart:
          type: 'line'
        #credits:
          #enabled: false
        tooltip:
          borderRadius: 0
          borderWidth: 0
          shared: true
          crosshairs: true
          useHTML: true
          formatter: ->
            # load game result...
            console.log "load game result of game with index #{this.x}"
            gameresultMeta = timeSeries.meta[this.x - 1]
            $http.get("/api/gameresults/#{gameresultMeta.gameresult}").then (res)->
              gameresult = res.data
              tooltipSelector = "#tooltip_#{res.data._id}"
              game = $sanitize(gameresult.game.name)
              players = _.chain(gameresult.scores)
                .sortBy((item)-> -item.score)
                .map((score)-> $sanitize("#{score.player.name}: #{score.score}"))
                .value()
              html = "<b>#{game}</b><br>#{players.join('<br>')}"
              angular.element(tooltipSelector).removeClass('loading-spinner').html(html)

            header = "<b>#{moment(gameresultMeta.time).format('LL')}<br><br></b><div class='loading-spinner' id='tooltip_#{gameresultMeta.gameresult}'></div><br><b>Ranking:</b>"
            points = _.sortBy(this.points, (point)-> -point.point.y)
            points = _.reduce(points, ((memo, point)->
              player = "#{point.series.name}: #{point.y}<br>"
              memo + player)
              , '')
            "#{header}<br>#{points}"
        exporting:
          enabled: false
        plotOptions:
          series:
            cursor: 'pointer'
            point:
              events:
                click: (e)->
                  $state.go '.gameresults.gameresult',
                    gameresult: this.gameresult
          line:
            marker:
              enabled: false
      # higharts-ng options
      title: text: ''
      subtitle: text: ''
      xAxis:
        title:
          text: ''
      yAxis:
        title:
          text: 'Score'
      series: timeSeries.series
      func: (c)->
        $scope.chartLoading = false
        $scope.timeChartStyle = {}
        $timeout (-> c.reflow()), 0

  # create the chart
  $scope.$watch 'timeSeries', createChart
  createChart($scope.timeSeries)
