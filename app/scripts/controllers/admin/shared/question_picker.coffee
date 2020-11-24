'use strict'

module = angular.module('dcida20App')

module.filter 'onlyQuestionType', (_) ->
  (input, qt) ->
    if input
      _.filter input, (question) => question.question_type is qt
    else
      []

module.filter 'questionVisibility', (_) ->
  (input, qv) ->
    if input
      _.filter input, (question) => question.hidden is qv
    else
      []

module.filter 'onlyQuestionResponseTypes', (_) ->
  (input, rts) ->
    #console.log rts
    #console.log input
    foundResponseTypes = {}
    _.filter input, (question) => 
      if foundResponseTypes[question.question_response_type]
        foundResponseTypes[question.question_response_type].selected
      else
        rt = _.find(rts, (rt) => rt.questionResponseType is question.question_response_type)
        if rt
          foundResponseTypes[rt.questionResponseType] = rt
          rt.selected
        else
          false

class QuestionPickerCtrl
  @$inject: ['$scope', '$uibModalInstance', 'Question', 'options', '_', '$filter']
  constructor: (@$scope, @$uibModalInstance, @Question, options, @_, @$filter) ->
    @$scope.ctrl = @

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      @$uibModalInstance.dismiss('cancel')

    @description = options.descriptionText
    @includeNumeric = options.includeNumeric
    @gridSelectable = options.gridSelectable
    @skipMetadataSelection = options.skipMetadataSelection
    @loading = true

    @questionTypeFilters = @_.map options.questionType.split(","), (qt) =>
      {
        questionType: qt,
        key: @$filter('capitalize')(qt)
      }
    @currentQuestionType = @questionTypeFilters[0].questionType
    @questionResponseTypeFilters = @_.map options.questionResponseType.split(","), (qrt) =>
      {
        questionResponseType: qrt,
        key: @$filter('underscoreless')(@$filter('capitalize')(qrt)),
        selected: true
      }

    @hiddenFilters = [
      {
        hidden: false,
        key: "Visible Questions"
      },
      {
        hidden: true,
        key: "Data Sources"
      }
    ]
    @currentHiddenFilter = false

    @Question.query {decision_aid_id: options.decisionAidId, flatten: options.flatten, include_responses: options.includeResponses, question_type: options.questionType, question_response_type: options.questionResponseType, include_hidden: options.includeHidden}, (questions) =>
      if options.flatten
        @questions = questions #@Question.unflattenQuestions(questions)
      else
        @questions = questions
      @loading = false

  clearCurrentQuestion: () ->
    @selectedQuestion.additional_meta = null
    @selectedQuestion = null

  setSelectedQuestion: (question) ->
    if @gridSelectable || question.question_response_type isnt "grid"
      @selectedQuestion = question

      if @skipMetadataSelection
        @selectQuestion()

  selectQuestion: () ->
    @$uibModalInstance.close(@selectedQuestion)

  cancelQuestionPicker: () ->
    @$uibModalInstance.dismiss('cancel')


module.controller 'QuestionPickerCtrl', QuestionPickerCtrl

