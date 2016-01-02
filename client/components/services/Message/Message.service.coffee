'use strict'

angular.module 'shpeelyApp'
.factory 'Message', ($resource)->
  $resource '/api/messages/:id/:controller',
    id: '@_id'
  ,
    count:
      method: 'GET'
      params:
        controller: 'count'
    acceptMembershipRequest:
      method: 'GET'
      params:
        controller: 'acceptMembershipRequest'
    denyMembershipRequest:
      method: 'GET'
      params:
        controller: 'denyMembershipRequest'


