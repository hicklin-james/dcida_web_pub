'use strict'

angular.module('dcida20App')
  .factory 'DceQuestionSetResponse', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['description']
    actions = Util.resourceActions 'dce_question_set_response', 'dce_question_set_responses', attributes

    DceQuestionSetResponse = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/dce_question_set_responses/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    DceQuestionSetResponse.preview = (decisionAidId) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/dce_question_set_responses/preview")
        .success((data) ->
          d.resolve(data.dce_question_set_responses)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DceQuestionSetResponse
  ]
