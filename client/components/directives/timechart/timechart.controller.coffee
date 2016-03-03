'use strict'

angular.module 'shpeelyApp'
.controller 'TimeChartCtrl', ($scope, $timeout, $http, $sanitize, $state, $window) ->

  chart = null

  fromTime = null
  $scope.changeTimespan = (newFromTime)->
    fromTime = newFromTime
    createChart $scope.timeSeries

  $scope.chartLoading = true

  $scope.timeChartStyle =
    width: $window.innerWidth - 50 + 'px'
    display: 'none'

  showHideAll = (show)->
    window.timechartConfig = $scope.timechartConfig
    #chart = $scope.timechartConfig.getHighcharts()
    _.each chart.series, (serie)->
      serie.setVisible show, false
    chart.redraw()

  $scope.showAll = -> showHideAll(true)
  $scope.hideAll = -> showHideAll(false)

  createChart = (timeSeries)->

    if !(timeSeries and fromTime) then return

    timeSeries = angular.copy timeSeries

    # unless the starting time is 1970 we need to "cut off" all data before
    # the selected time.
    if fromTime.getTime()
      firstIndex = _.findIndex timeSeries.meta, (result, i)-> result.time > fromTime.getTime()
      if firstIndex < 0 then firstIndex = timeSeries.series[0].data.length
      reverseIndex = timeSeries.meta.length - firstIndex

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
                    gameresult: timeSeries.meta[this.x - 1].gameresult
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
        chart = c

  # create the chart
  $scope.$watch 'timeSeries', createChart
  createChart($scope.timeSeries)
