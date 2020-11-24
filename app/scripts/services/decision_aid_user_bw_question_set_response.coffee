'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUserBwQuestionSetResponse', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['bw_question_set_response_id', 'question_set', 'best_property_level_id', 'worst_property_level_id']
    actions = Util.resourceActions 'decision_aid_user_bw_question_set_response', 'decision_aid_user_bw_question_set_responses', attributes

    DecisionAidUserBwQuestionSetResponse = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/decision_aid_user_bw_question_set_responses/:id", { id: '@id', decision_aid_user_id: '@user_id' }, actions

    DecisionAidUserBwQuestionSetResponse.findByQuestionSet = (questionSet, decision_aid_user) ->
      d = $q.defer()
      ps = 
        question_set: questionSet
      $http.get("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user.id}/decision_aid_user_bw_question_set_responses/find_by_question_set", 
                 params: ps)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise


    return DecisionAidUserBwQuestionSetResponse
  ]
