
angular.module 'shpeelyApp'
.controller 'ScoreChartCtrl', ($scope, $timeout, $window) ->

  $scope.chartLoading = true

  $scope.scoreChartStyle =
    width: $window.innerWidth - 50 + 'px'
    display: 'none'

  createChart = (scores)->
    if not scores then return

    data = _.chain scores
      .pluck 'score'
      .map (score) -> {color: (if score < 0 then '#E74C3C' else '#18BC9C'), y: score}
      .value()

    players = _.pluck(scores, 'player')

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
        categories: _.chain(scores).pluck('player').pluck('name').value()
      yAxis:
        title:
          text: 'Score'
      func: (c)->
        $scope.chartLoading = false
        $scope.scoreChartStyle = {}
        $timeout (-> c.reflow()), 0

  $scope.$watch 'scores', createChart
  createChart($scope.scores)
