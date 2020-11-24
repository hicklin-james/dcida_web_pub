'use strict'

angular.module('dcida20App')
  .factory 'Option', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['option_id', 'id', '_destroy', 'sub_decision_id', 'description', 'label', 'has_sub_options', 'title', 'summary_text', 'media_file_id', 'question_response_array', 'sub_options_attributes', 'decision_aid_id', 'generic_name']
    actions = Util.resourceActions 'option', 'options', attributes

    Option = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/options/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    Option.prototype.initialize = (decisionAidId, subDecisionId) ->
      @decision_aid_id = decisionAidId
      @sub_options = []
      #if isSubQuestion
      @has_sub_options = false
      @sub_decision_id = subDecisionId

    Option.prototype.copyAttributes = (option) ->
      @title = angular.copy option.title
      @label = angular.copy option.label
      @question_response_array = angular.copy option.question_response_array
      @decision_aid_id = angular.copy option.decision_aid_id
      @summary_text = angular.copy option.summary_text
      @description = angular.copy option.description
      @image = angular.copy option.image
      @image_thumb = angular.copy option.image_thumb
      @media_file_id = angular.copy option.media_file_id
      @sub_decision_id = angular.copy option.sub_decision_id
      @generic_name = angular.copy option.generic_name

    Option.prototype.setupQuestionResponses = () ->
      _.each @questions_with_responses, (q) =>
        _.each q.question_responses, (qr) =>
          if _.contains(@question_response_array, qr.id)
            qr.selected = true
          else
            qr.selected = false

    Option.prototype.updateQuestionResponses = () ->
      responses = []
      _.each @questions_with_responses, (q) =>
        _.each q.question_responses, (qr) =>
          if qr.selected
            responses.push qr.id
      @question_response_array = responses

    Option.prototype.prepareForSubmit = () ->
      @cleaned_sub_options = _.map @sub_options, (so) ->
        _.pick so, attributes
      @sub_options_attributes = @cleaned_sub_options

    Option.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/options/#{@id}/update_order", {option: @})
        .success((data) ->
          d.resolve(data.option)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    Option.preview = (decisionAidId) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/options/preview")
        .success((data) ->
          d.resolve(data.options)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    Option.getOptionsFromSubDecision = (decisionAidId, subDecisionOrder = null) =>
      d = $q.defer()
      data = if subDecisionOrder then {sub_decision_order: subDecisionOrder} else null
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/options/options_from_last_sub_decision", {params: data} )
        .success((data) ->
          d.resolve(data.options)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    Option.prototype.clone = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/options/#{@id}/clone")
        .success((data) ->
          d.resolve(data.option)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise


    return Option
  ]
