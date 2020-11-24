'use strict'

angular.module('dcida20App')
  .factory 'Question', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['question_text', 'question_type', 'sub_decision_id', 'question_response_style', 
                  'question_response_type', 'question_responses_attributes', 'grid_questions_attributes', 
                  'order', 'hidden', 'response_value_calculation', 'lookup_table_dimensions', 'lookup_table'
                  'remote_data_source', 'remote_data_source_type', 'redcap_field_name', 'current_treatment_option_ids',
                  'slider_left_label', 'slider_right_label', 'slider_granularity', 'num_decimals_to_round_to',
                  'can_change_response', 'unit_of_measurement', 'slider_midpoint_label', 'post_question_text',
                  'side_text', 'skippable', 'is_exclusive', 'randomized_response_order', 'min_number', 'max_number', 
                  'min_chars', 'max_chars', 'units_array', 'remote_data_target', 'remote_data_target_type',
                  'backend_identifier', 'question_page_id']
    actions = Util.resourceActions 'question', 'questions', attributes

    Question = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/questions/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    Question.prototype.prepareSkipLogicDataForSave = (deletedSlts, deletedSlcs) ->
      _.each @question_responses, (qr) =>
        qr.skip_logic_targets_attributes = qr.skip_logic_targets
        if qr.skip_logic_targets && qr.skip_logic_targets.length > 0
          qr.skip_logic_targets_attributes[0].skip_logic_target_order = 1
        if qr.deletedSkipLogicTarget
          qr.skip_logic_targets_attributes.push qr.deletedSkipLogicTarget
          delete qr.deletedSkipLogicTarget

    Question.flattenQuestions = (qs) ->
      allQuestions = []
      _.each qs, (q) ->
        allQuestions.push q
        if q.question_response_type is "grid"
          _.each q.grid_questions, (gq) =>
            allQuestions.push gq
      allQuestions

    Question.prototype.addDestroyedGridQuestions = (dgqs) ->
      if @question_response_type is "grid"
        @grid_questions_attributes = @grid_questions
        @grid_questions_attributes = @grid_questions_attributes.concat dgqs

    Question.prototype.addDestroyedQuestionResponses = (dqrs) ->
      if @question_response_type is "radio" or 
         @question_response_type is "yes_no" or 
         @question_response_type is "ranking" or
         @question_response_type is "sum_to_n"
         
        @question_responses_attributes = @question_responses
        @question_responses_attributes = @question_responses_attributes.concat dqrs

    Question.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/questions/#{@id}/update_order", {question: @})
        .success((data) ->
          d.resolve(data.question)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    Question.prototype.moveQuestionToPage = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/questions/#{@id}/move_question_to_page", {question: @})
        .success((data) ->
          d.resolve(data.question)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    Question.preview = (decisionAidId, questionType) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/questions/preview", {params: {question_type: questionType}})
        .success((data) ->
          d.resolve(data.questions)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    Question.prototype.clone = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/questions/#{@id}/clone")
        .success((data) ->
          d.resolve(data.question)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    Question.prototype.testRedcapQuestion = (redcap_variable) ->
      d = $q.defer()
      params = 
        redcap_question_variable: redcap_variable
      $http.get "#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/questions/test_redcap_question", params: params
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise



    return Question
  ]
