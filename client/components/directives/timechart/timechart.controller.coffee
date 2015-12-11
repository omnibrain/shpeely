'use strict'

angular.module 'boardgametournamentApp'
.controller 'TimeChartCtrl', ($scope, Tournament, $timeout, $http, $sanitize) ->

  $scope.chartLoading = true

  showHideAll = (show)->
    chart = $scope.timechartConfig.getHighcharts()
    _.each chart.series, (serie)->
      serie.setVisible show, false
    chart.redraw()

  $scope.showAll = ()-> showHideAll(true)
  $scope.hideAll = ()-> showHideAll(false)

  # get the scores
  Tournament.getTimeSeries().then (timeSeries)->

    $scope.chartLoading = false

    $scope.timechartConfig =
      options:
        chart:
          type: 'line'
        credits:
          enabled: false
        tooltip:
          borderRadius: 0
          borderWidth: 0
          shared: true
          crosshairs: true
          useHTML: true
          formatter: ->
            # load game result...
            $http.get("/api/gameresults/#{this.points[0].point.gameresult}").then (res)->
              gameresult = res.data
              tooltipSelector = "#tooltip_#{res.data._id}"
              game = $sanitize(gameresult.game.name)
              players = _.chain(gameresult.scores)
                .sortBy((item)-> -item.score)
                .map((score)-> $sanitize("#{score.player.name}: #{score.score}"))
                .value()
              html = "<b>#{game}</b><br>#{players.join('<br>')}"
              angular.element(tooltipSelector).removeClass('loading-spinner').html(html)

            header = "<b>#{moment(this.points[0].point.time).format('LL')}<br><br></b><div class='loading-spinner' id='tooltip_#{this.points[0].point.gameresult}'></div><br><b>Ranking:</b>"
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
                  console.log this
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
      series: timeSeries
      func: (c)->
        $timeout (-> c.reflow()), 0
