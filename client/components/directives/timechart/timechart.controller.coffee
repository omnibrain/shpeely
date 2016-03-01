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

  $scope.showAll = ()-> showHideAll(true)
  $scope.hideAll = ()-> showHideAll(false)

  createChart = (timeSeries)->

    if not timeSeries then return

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
