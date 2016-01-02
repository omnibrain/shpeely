'use strict'

angular.module 'shpeelyApp'
.filter 'capitalize', ->
  (input) ->
    if input then input.charAt(0).toUpperCase() + input.slice(1) else ''
