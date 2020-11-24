'use strict'

angular.module('dcida20App')
  .factory 'DceQuestionSet', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['id', 'question_title']
    actions = Util.resourceActions 'dce_question_set', 'dce_question_sets', attributes

    DceQuestionSet = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/dce_question_sets/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    DceQuestionSet.updateBulk = (decision_aid_id, dce_question_sets) ->
      d = $q.defer()
      #console.log params
      $http.post("#{API_ENDPOINT}/decision_aids/#{decision_aid_id}/dce_question_sets/update_bulk", {dce_question_sets: items: dce_question_sets})
        .success((data) ->
          #data.$metadata = data.meta
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DceQuestionSet
  ]
