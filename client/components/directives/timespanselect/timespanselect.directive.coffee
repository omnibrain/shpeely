'use strict'

angular.module 'shpeelyApp'
.directive 'timespanselect', ->
  templateUrl: 'components/directives/timespanselect/timespanselect.html'
  restrict: 'E'
  scope:
    onChange: '&'
  link: (scope, element, attrs) ->

    currentMoment = moment()
    scope.timespanOptions = [
      { name: "Year #{currentMoment.format('YYYY')}",   date: moment().startOf('year').toDate() }
      { name: "#{currentMoment.format('MMMM YYYY')}",   date: moment().startOf('month').toDate() }
      { name: "Past Year",   date: moment().subtract(1, 'year').toDate() }
      { name: "Past 6 Month",   date: moment().subtract(6, 'month').toDate() }
      { name: "Past 30 Days",   date: moment().subtract(30, 'days').toDate() }
      { name: "Past 7 Days",   date: moment().subtract(7, 'days').toDate() }
      { name: "All Time",   date: new Date(0), bold: true}
    ]

    scope.selectTimespan = (index)->
      scope.selectedTimespan = scope.timespanOptions[index].name
      console.log "change!"
      scope.onChange(fromTime: scope.timespanOptions[index].date)

    # initial selection
    scope.selectTimespan 0
