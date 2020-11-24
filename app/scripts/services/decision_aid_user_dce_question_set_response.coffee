'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUserDceQuestionSetResponse', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['dce_question_set_response_id', 'question_set', 'fallback_question_set_id', 'option_confirmed']
    actions = Util.resourceActions 'decision_aid_user_dce_question_set_response', 'decision_aid_user_dce_question_set_responses', attributes

    DecisionAidUserDceQuestionSetResponse = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/decision_aid_user_dce_question_set_responses/:id", { id: '@id', decision_aid_user_id: '@user_id' }, actions

    DecisionAidUserDceQuestionSetResponse.findByQuestionSet = (questionSet, decision_aid_user) ->
      d = $q.defer()
      ps = 
        question_set: questionSet
      $http.get("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user.id}/decision_aid_user_dce_question_set_responses/find_by_question_set", 
                 params: ps)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise


    return DecisionAidUserDceQuestionSetResponse
  ]
