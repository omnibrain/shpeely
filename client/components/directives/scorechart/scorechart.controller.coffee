
angular.module 'shpeelyApp'
.controller 'ScoreChartCtrl', ($scope, $timeout, $window) ->

  $scope.chartLoading = true

  $scope.scoreChartStyle =
    width: $window.innerWidth - 50 + 'px'
    display: 'none'

  fromTime = null
  $scope.changeTimespan = (newFromTime)->
    fromTime = newFromTime
    createChart $scope.timeSeries

  createChart = (timeSeries)->
    if !(fromTime and timeSeries) then return

    firstIndex = _.findIndex timeSeries.meta, (result, i)-> result.time > fromTime.getTime()
    if firstIndex < 0 then firstIndex = timeSeries.series[0].data.length

    reverseIndex = timeSeries.meta.length - firstIndex

    data = _.map timeSeries.series, (serie)->
      subtract = 0
      if serie.data.length > reverseIndex
        subtract = serie.data[(serie.data.length - reverseIndex) - 1].y

      score: (_.last serie.data).y - subtract
      player:
        name: serie.name

    data = _.chain(data)
      .filter (e)-> e.score
      .sortBy (e)-> -e.score
      .value()

    players = _.map data, 'player.name'
    data = _.chain data
      .map 'score'
      .map (score) -> {color: (if score < 0 then '#E74C3C' else '#18BC9C'), y: score}
      .value()

    $scope.scorechartConfig =
      options:
        chart:
          type: 'column'
        exporting:
          enabled: false
        #credits:
          #enabled: false
      # higharts-ng options
      title:
        text: ''
      series: [ {
        name: 'Score'
        showInLegend: false
        data: data
      } ]
      xAxis:
        categories: players
      yAxis:
        title:
          text: 'Score'
      func: (c)->
        $scope.chartLoading = false
        $scope.scoreChartStyle = {}
        $timeout (-> c.reflow()), 0

  $scope.$watch 'timeSeries', createChart
  createChart($scope.timeSeries)
