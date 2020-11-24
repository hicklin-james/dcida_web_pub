'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUserSubDecisionChoice', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['option_id', 'sub_decision_id']
    actions = Util.resourceActions 'decision_aid_user_sub_decision_choice', 'decision_aid_user_sub_decision_choices', attributes

    DecisionAidUserSubDecisionChoice = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/decision_aid_user_sub_decision_choices/:id", { id: '@id', decision_aid_user_id: '@user_id' }, actions

    DecisionAidUserSubDecisionChoice.findBySubDecision = (decision_aid_user_id, sub_decision_id) ->
      d = $q.defer()
      data = 
        sub_decision_id: sub_decision_id
      $http.get("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user_id}/decision_aid_user_sub_decision_choices/find_by_sub_decision_id", params: data)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DecisionAidUserSubDecisionChoice
  ]
