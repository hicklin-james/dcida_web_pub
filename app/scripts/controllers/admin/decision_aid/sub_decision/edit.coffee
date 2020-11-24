'use strict'

module = angular.module('dcida20App')

class SubDecisionEditCtrl
  @$inject: ['$scope', '$state', '$q', '$uibModal', '$stateParams', 'DecisionAid', 'SubDecision', 'Option', '_', 'Confirm']
  constructor: (@$scope, @$state, @$q, @$uibModal, @$stateParams, @DecisionAid, @SubDecision, @Option, @_, @Confirm) ->
    @$scope.ctrl = @
    @showErrors = false
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId

    @initSubDecision().then () =>
      @getOptionsFromPreviousDecision()

  initSubDecision: () ->
    d = @$q.defer()
    if @$stateParams.id
      @isNewSubDecision = false
      @getSubDecision().then () =>
        d.resolve()
    else
      @isNewSubDecision = true
      @title = "New Sub Decision"
      @subDecision = new @SubDecision
      @subDecision.required_option_ids = []
      d.resolve()
    d.promise

  getSubDecision: () ->
    d = @$q.defer()
    @SubDecision.get {id: @$stateParams.id, decision_aid_id: @decisionAidId}, (sd) =>
      @subDecision = sd
      @title = "Edit Decision #{@subDecision.sub_decision_order}"
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  getOptionsFromPreviousDecision: () ->
    @Option.getOptionsFromSubDecision(@decisionAidId, @subDecision.sub_decision_order).then (options) =>
      @options = options
      @setupOptions()
      @loading = false

  setSubOptions: (option) ->
    if option.has_sub_options
      @_.each option.sub_options, (so) => so.selected = option.selected

  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  setupOptions: () ->
    @_.each @options, (o) =>
      @_.each o.sub_options, (so) =>
        if @subDecision.required_option_ids.indexOf(so.id) > -1
          so.selected = true
      if @subDecision.required_option_ids.indexOf(o.id) > -1
        o.selected = true

  saveSubDecision: () ->
    selectedOptions = []
    @_.each @options, (o) =>
      @_.each o.sub_options, (so) =>
        if so.selected
          selectedOptions.push so.id
      if o.selected
        selectedOptions.push o.id
    @subDecision.required_option_ids = selectedOptions
    if @isNewSubDecision
      @subDecision.$save {decision_aid_id: @decisionAidId}, ((sd) =>  @$state.go 'decisionAidShow.myOptions', {decisionAidId: @$stateParams.decisionAidId}), ((error) => @handleError(error))
    else
      @subDecision.$update {decision_aid_id: @decisionAidId}, ((sd) =>  @$state.go 'decisionAidShow.myOptions', {decisionAidId: @$stateParams.decisionAidId}), ((error) => @handleError(error))


module.controller 'SubDecisionEditCtrl', SubDecisionEditCtrl

