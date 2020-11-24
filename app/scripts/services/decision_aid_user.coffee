'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUser', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['selected_option_id', 'other_properties']
    actions = Util.resourceActions 'decision_aid_user', 'decision_aid_users', attributes

    DecisionAidUser = $resource "#{API_ENDPOINT}/decision_aid_users/:id", { id: '@id' }, actions

    DecisionAidUser.prototype.updateFromProperties = () ->
      d = $q.defer()

      $http.post "#{API_ENDPOINT}/decision_aid_users/#{@id}/update_from_properties", decision_aid_user: @
        .success((data) ->
          d.resolve(data.decision_aid_user)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DecisionAidUser
  ]
