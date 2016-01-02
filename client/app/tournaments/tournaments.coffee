'use strict'

angular.module 'shpeelyApp'
.config ($stateProvider) ->
  $stateProvider.state 'tournaments',
    url: '/tournaments'
    templateUrl: 'app/tournaments/tournaments.html'
    controller: 'TournamentsCtrl'
    authenticate: true
    resolve:
      tournaments: (Tournament)-> Tournament.promise
