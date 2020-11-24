'use strict'

module = angular.module('dcida20App')

class SummaryPanelEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', 'Option', '$stateParams', 'DecisionAid', 'SummaryPanel', 'Confirm', 'Sortable', '$q', 'Question', '_', 'SubDecision']
  constructor: (@$scope, @$state, @$uibModal, @Option, @$stateParams, @DecisionAid, @SummaryPanel, @Confirm, @Sortable, @$q, @Question, @_, @SubDecision) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId

    promises = []
    
    @summaryPanelTypes = [
      key: "Text"
      value: "text"
     ,
      key: "Decision Summary"
      value: "decision_summary"
    ]
    
    #  key: "Question Responses"
    #  value: "question_responses"

    if @$stateParams.id
      @isNewSummaryPanel = false
      @title = "Edit Summary Panel"
      promises.push @getSummaryPanel(@$stateParams.id)
    else
      @isNewSummaryPanel = true
      @title = "New Summary Panel"
      @summaryPanel = new @SummaryPanel
      @summaryPanel.summary_page_id = @$stateParams.summary_page_id
      @summaryPanel.question_ids = []

    promises.push @getQuestions()
    promises.push @getOptions()
    promises.push @getSubDecisions()

    @$q.all(promises).then (p1, p2) =>
      @questionHash = {}
      @_.each @questions, (q) =>
        if @summaryPanel.question_ids.indexOf(q.id) >= 0
          @questionHash[q.id] = true
        else
          @questionHash[q.id] = false
        if q.grid_questions.length > 0
          @_.each q.grid_questions, (gq) =>
            if @summaryPanel.question_ids.indexOf(gq.id) >= 0
              @questionHash[gq.id] = true
            else
              @questionHash[gq.id] = false

      @loading = false

  getQuestions: () ->
    d = @$q.defer()
    @Question.query {decision_aid_id: @$stateParams.decisionAidId, include_responses: true}, (questions) =>
      @questions = @_.sortBy(questions, "question_type")
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  getSummaryPanel: (id) ->
    d = @$q.defer()
    @SummaryPanel.get { id: id, decision_aid_id: @$stateParams.decisionAidId }, (summaryPanel) =>
      @summaryPanel = summaryPanel
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  getOptions: () ->
    d = @$q.defer()
    @Option.query {decision_aid_id: @$stateParams.decisionAidId}, (options) =>
      @options = options
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  getSubDecisions: () ->
    d = @$q.defer()
    @SubDecision.query {decision_aid_id: @$stateParams.decisionAidId}, (sub_decisions) =>
      @sub_decisions = sub_decisions
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  toggleQuestion: (question) ->
    @questionHash[question.id] = !@questionHash[question.id]

  deleteSummaryPanel: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this summary panel?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @summaryPanel.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.summary", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
  
  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  saveSummaryPanel: () ->
    @summaryPanel.question_ids = @_.keys(@_.pick(@questionHash, (bool, key) => bool))
    if @isNewSummaryPanel
      @summaryPanel.$save {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.summary", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
    else
      @summaryPanel.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.summary", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))


module.controller 'SummaryPanelEditCtrl', SummaryPanelEditCtrl

