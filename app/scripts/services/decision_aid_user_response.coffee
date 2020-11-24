'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUserResponse', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['id', 'question_response_id', 'response_value', 'number_response_value', 'option_id', 'question_id', 'json_response_value', 'selected_unit', 'question_ids']
    actions = Util.resourceActions 'decision_aid_user_response', 'decision_aid_user_responses', attributes

    DecisionAidUserResponse = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/decision_aid_user_responses/:id", { id: '@id', decision_aid_user_id: '@user_id' }, actions

    DecisionAidUserResponse.prototype.initialize = (question, decision_aid_user) ->
      @question_id = question.id
      @decision_aid_user_id = decision_aid_user.id

    DecisionAidUserResponse.createAndUpdateBulk = (responses, decision_aid_user_id, question_type, question_page_id) ->
      d = $q.defer()
      params = responses
      $http.post("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user_id}/decision_aid_user_responses/create_and_update_bulk", {question_type: question_type, decision_aid_user_responses: params, question_page_id: question_page_id})
        .success((data) ->
          data.$metadata = data.meta
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAidUserResponse.createOrUpdateRadioFromChatbot = (decision_aid_user_id, question_id, question_response_value) ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user_id}/decision_aid_user_responses/create_or_update_radio_from_chatbot", {question_id: question_id, question_response_value: question_response_value})
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAidUserResponse.createMissingResponses = (responses, questions, decision_aid_user) ->
      # combine questions and grid questions
      allQuestions = []
      _.each questions, (q) =>
        allQuestions.push q
        if q.question_response_type is 'grid'
          _.each q.grid_questions, (gq) =>
            allQuestions.push gq
      # find the questions that don't have responses
      difference = _.filter allQuestions, (q) => !_.find responses, (r) => r.question_id is q.id
      # create a new response for each of the difference questions
      newResponses = []
      _.each difference, (q) =>
        r = new DecisionAidUserResponse()
        r.initialize(q, decision_aid_user)
        newResponses.push r
      newResponses

    return DecisionAidUserResponse
  ]
