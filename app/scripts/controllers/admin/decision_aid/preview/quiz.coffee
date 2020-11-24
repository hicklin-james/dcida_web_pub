'use strict'

module = angular.module('dcida20App')

class QuizPreviewCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'Question', '$uibModalInstance', 'options', '$q']
  constructor: (@$scope, @$state, @$location, @Auth, @Question, @$uibModalInstance, options, @$q) ->
    @$scope.ctrl = @
    @loading = true

    fullDa = options.decisionAid

    @$q.all([fullDa.preview(), @Question.preview(fullDa.id, "quiz")]).then (prs) =>
      @decisionAid = prs[0]
      @questions = prs[1]

      @currQuestion = null
      @loading = false

  setClasses: () ->
    if @currQuestion.question_response_type is "radio" and @currQuestion.question_response_style is "vertical_radio"
      #@setClassesHelper(@currQuestion.question_responses.length)
      @responseClass = "col-md-1"
      @questionClass = "col-md-11"
    else if @currQuestion.question_response_type is "grid"
      if @currQuestion.grid_questions[0]?.question_response_type is "radio"
        @setClassesHelper(@currQuestion.grid_questions[0].question_responses.length)
      else if @currQuestion.grid_questions[0]?.question_response_type is "yes_no"
        @responseClass = "col-md-1"
        @questionClass = "col-md-11"

  setClassesHelper: (numResponses) ->
    if numResponses <= 6
      responseDifference = 12 - numResponses
      @responseClass = "col-md-1"
      @questionClass = "col-md-#{responseDifference}"
    else
      @responseClass = "col-md-1"
      @questionClass = "col-md-4"

  close: () ->
    @$uibModalInstance.close()

  next: () ->
    if @currQuestion is null
      @currQuestion = @questions[0]
    else if @currQuestion.question_order - 1 < @questions.length - 1
      @currQuestion = @questions[@currQuestion.question_order]
    @setClasses()

  prev: () ->
    if @currQuestion.question_order is 1
      @currQuestion = null
    else
      @currQuestion = @questions[@currQuestion.question_order - 2]
      @setClasses()

module.controller 'QuizPreviewCtrl', QuizPreviewCtrl
