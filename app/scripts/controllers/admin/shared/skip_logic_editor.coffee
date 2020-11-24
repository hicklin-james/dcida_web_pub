'use strict'

module = angular.module('dcida20App')

module.filter 'htmlToPlaintext', () ->
  (input) ->
    String(input).replace(/<[^>]+>/gm, '')

module.filter 'ellipsify', () ->
  (input, length) ->
    if input.length > length
      input.slice(0, length) + "..."
    else
      input

class SkipLogicEditorCtrl
  @$inject: ['$scope', '$uibModalInstance', 'options', '_', 'SkipLogicTarget', 'SkipLogicCondition', '$uibModal', 'DceQuestionSet', 'DceQuestionSetResponse', '$q', 'DecisionAid', 'Question', 'QuestionPage', 'ErrorHandler']
  constructor: (@$scope, @$uibModalInstance, options, @_, @SkipLogicTarget, @SkipLogicCondition, @$uibModal, @DceQuestionSet, @DceQuestionSetResponse, @$q, @DecisionAid, @Question, @QuestionPage, @ErrorHandler) ->
    @$scope.ctrl = @

    @loading = true

    @decisionAidId = options.decisionAidId
    @questionPage = options.questionPage
    @skipLogicTargets = @questionPage.skip_logic_targets
    @deletedSkipLogicConditions = options.deletedSkipLogicConditions
    @deletedSkipLogicTargets = options.deletedSkipLogicTargets

    @targetEntities = [
      {
        key: 'Question Page',
        value: 'question_page'
      }
     ,{
        key: 'End of question section',
        value: 'end_of_questions'
     },{
        key: "External page",
        value: "external_page"
     },{
        key: "Skip to other section",
        value: "other_section"
      }
    ]

    @conditionEntities = [
      {
        key: "Always",
        value: "always"
      },
      {
        key: "DCE Question set response",
        value: "dce_question_set_response"
      },
      {
        key: "Question response",
        value: "question_response"
      }
    ]

    p1 = @getDecisionAid()
    p2 = @getDceQuestionSetData()
    p3 = @getDceQuestionSetResponseData()
    p4 = @getQuestionData()
    p5 = @getDecisionAidPages()
    p6 = @getQuestionPageData()

    promises = [p1.$promise, p2.$promise, p3.$promise, p4.$promise, p5, p6.$promise]

    @$q.all(promises).then (resolvedPromises) =>
      @setPageTargets(resolvedPromises[4].pages)

      @dceQuestionSets = @_.map @dceQuestionSets, (dqs) =>
        return {
          questionSetValue: dqs.dce_question_set_order.toString(),
          displayValue: dqs.question_title
        }

      stringMap = ["A", "B", "C", "D", "E", "F", "G", "H"]
      @dceQuestionSetResponses = @_.map @dceQuestionSetResponses, (dqsr) =>
        return {
          responseValue: dqsr.response_value.toString(),
          displayValue: if dqsr.response_value > 0 then @decisionAid.dce_option_prefix + " " + stringMap[dqsr.response_value-1] else @decisionAid.opt_out_label
        }

      @loading = false

  getDecisionAidPages: () ->
    @DecisionAid.getPages(@decisionAidId)

  getDecisionAid: () ->
    @DecisionAid.get {id: @decisionAidId }, (decisionAid) =>
      @decisionAid = decisionAid

  getDceQuestionSetData: () ->
    @DceQuestionSet.query {decision_aid_id: @decisionAidId}, (dceQuestionSets) =>
      @dceQuestionSets = dceQuestionSets

  getDceQuestionSetResponseData: () ->
    @DceQuestionSetResponse.query {decision_aid_id: @decisionAidId, question_set: 1, block: 1}, (dceQuestionSetResponses) =>
      @dceQuestionSetResponses = dceQuestionSetResponses

  getQuestionData: () ->
    @Question.query {decision_aid_id: @decisionAidId, question_response_type: "radio,grid,yes_no", include_responses: true}, (questions) =>
      @questions = []
      @_.each questions, (q) =>
        @questions.push q
        if q.question_response_type is "grid"
          @_.each q.grid_questions, (gq) =>
            @questions.push gq
      
  setPageTargets: (pageTargets) ->
    capitalize = (s) =>
      if typeof s isnt 'string'
        return ''
      return s.charAt(0).toUpperCase() + s.slice(1)

    @skipSectionTargets = @_.map pageTargets, (pt) =>
      {
        key: @_.map(pt.split("_"), (word) => capitalize(word)).join(" "),
        value: pt
      }

  getQuestionPageData: () ->
    section = @questionPage.section
    @QuestionPage.query {decision_aid_id: @decisionAidId, section: section}, (questionPages) =>
      @questionPages = questionPages
      @_.each @questionPages, (qp) =>
        qp.name = "Question Page " + qp.question_page_order
      #@questions = questions

  addSkipLogicTarget: () ->
    slt = @SkipLogicTarget.buildSkipLogicTarget(@decisionAidId)
    @skipLogicTargets.push slt

  addSkipLogicCondition: (slt) ->
    slc = @SkipLogicCondition.buildSkipLogicCondition(@decisionAidId)
    slt.skip_logic_conditions.push slc

  switchQuestionId: (id) ->
    question = @_.find @questions, (q) => q.id is parseInt(id)
    if question
      question.question_response_type

  responsesForQuestion: (id) ->
    question = @_.find @questions, (q) => q.id is parseInt(id)
    if question
      question.question_responses
    else
      []

  removeSkipLogicCondition: (slc, slt, removeInd) ->
    if slc.id and slt.id
      @deletedSkipLogicConditions[slt.id].push slc
      @deletedSkipLogicConditions[slt.id][@deletedSkipLogicConditions[slt.id].length-1]._destroy = 1

    slt.skip_logic_conditions.splice(removeInd, 1)

  removeSkipLogicTarget: (slt, removeInd) ->
    if slt.id
      @deletedSkipLogicTargets.push slt
      @deletedSkipLogicTargets[@deletedSkipLogicTargets.length-1]._destroy = 1 

    @skipLogicTargets.splice(removeInd, 1)

  openQuestionPicker: (slt) ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/question_picker.html"
      controller: "QuestionPickerCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAidId: @decisionAidId
          questionType: (if @questionPage.section == "about" then "demographic" else "quiz")
          flatten: false
          includeHidden: false
          gridSelectable: true
          questionResponseType: 'radio,text,number,yes_no,grid,current_treatment,heading,slider,ranking'
          descriptionText: 'Select a question from the list of questions.'
    )

    modalInstance.result.then (question) =>
      slt.skip_question_id = question.id

  saveQuestionPage: () ->
    @questionPage.prepareSkipLogicDataForSave(@deletedSkipLogicTargets, @deletedSkipLogicConditions)
    @questionPage.skip_logic_targets = @skipLogicTargets

    @questionPage.$update {decision_aid_id: @decisionAidId}, ((nqp) => 
      nqp = new @QuestionPage(nqp)
      nqp.page_questions = @_.map nqp.page_questions, (q) => new @Question(q)
      
      @$uibModalInstance.close(nqp)
    ), ((error) => 
      @handleError(error)
    )

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)
    console.log @errors

  closeSkipLogicEditor: () ->
    @saveQuestionPage()

  cancel: () ->
    @$uibModalInstance.dismiss()

module.controller 'SkipLogicEditorCtrl', SkipLogicEditorCtrl

