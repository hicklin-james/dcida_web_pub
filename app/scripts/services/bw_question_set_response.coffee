'use strict'

angular.module('dcida20App')
  .factory 'BwQuestionSetResponse', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    
    #attributes = ['description']
    #actions = Util.resourceActions 'dce_question_set_response', 'dce_question_set_responses', attributes

    #DceQuestionSetResponse = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/dce_question_set_responses/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions
    BwQuestionSetResponse = {}
    
    BwQuestionSetResponse.preview = (decisionAidId) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/bw_question_set_responses/preview")
        .success((data) ->
          d.resolve(data.bw_question_set_responses)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return BwQuestionSetResponse
  ]
