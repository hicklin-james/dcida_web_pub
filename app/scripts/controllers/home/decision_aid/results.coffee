'use strict'

module = angular.module('dcida20App')

class DecisionAidResultsCtrl
  @$inject: ['$scope', '$state', '$timeout', 'Confirm', '$stateParams', 
             'DecisionAidHome', 'DecisionAidUserSubDecisionChoice', 'DecisionAidUser', 
             'DecisionAidUserProperty', 'DecisionAidUserOptionProperty', 'moment', 'Auth', 
             '_', '$uibModal', '$document', 'Util', '$q', 'StandardResultsCtrl', 
             'DceResultsCtrl', 'BestWorstResultsCtrl', 'TraditionalResultsCtrl', 
             'TraditionalNoRankingsResultsCtrl', 'StandardEnhancedResultsCtrl',
             'NavBroadcastService', 'StateChangeRequested']

  constructor: (@$scope, @$state, @$timeout, @Confirm, @$stateParams, @DecisionAidHome, 
                @DecisionAidUserSubDecisionChoice, @DecisionAidUser, @DecisionAidUserProperty, 
                @DecisionAidUserOptionProperty, @moment, @Auth, @_, @$uibModal, @$document, 
                @Util, @$q, @StandardResultsCtrl, @DceResultsCtrl, @BestWorstResultsCtrl,
                @TraditionalResultsCtrl, @TraditionalNoRankingsResultsCtrl, @StandardEnhancedResultsCtrl, 
                @NavBroadcastService, @StateChangeRequested) ->
    
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @decisionAid = null
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

    @counter = 0

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null

    @subDecisionOrder = if @$stateParams.sub_decision_order then parseInt(@$stateParams.sub_decision_order) else 1

    @DecisionAidHome.results(@decisionAidSlug, @subDecisionOrder).then ((data) =>
      @subDecisionId = data.meta.sub_decision_id
      @decisionAid = data.decision_aid
      @decisionAidUser = new @DecisionAidUser data.meta.decision_aid_user
      @options = data.decision_aid.options
      @optionStartIndex = 0
      @properties = data.decision_aid.properties
      
      @optionProperties = data.decision_aid.option_properties
      @generateOptionPropertyHash()
      #console.log @optionPropertyHash

      promises = []
      promises.push @getSubDecisionChoice()

      switch @decisionAid.decision_aid_type
        when "standard"
          @rc = new @StandardResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties)
          promises.push @rc.generateDecisionAidUserOptionPropertiesHash()
        when "standard_enhanced"
          @rc = new @StandardEnhancedResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, data?.meta?.result_match_option)
          promises.push @rc.generateDecisionAidUserOptionPropertiesHash()        
        when "treatment_rankings"
          @rc = new @StandardResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, data?.meta?.result_match_option)   
          promises.push @rc.generateDecisionAidUserOptionPropertiesHash()
        when "dce"
          @rc = new @DceResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, data?.meta?.result_match_option)
          promises.push @rc.setupDceResultMatches()
        when "best_worst", "best_worst_with_prefs_after_choice"
          @rc = new @BestWorstResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, data?.meta?.result_match_option)
          promises.push @rc.setupBestWorstResult()
        when "traditional"
          @rc = new @TraditionalResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, @optionPropertyHash)
          promises.push @rc.generateDecisionAidUserOptionPropertiesHash()
        when "traditional_no_results"
          @rc = new @TraditionalNoRankingsResultsCtrl(@$scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, @optionPropertyHash)
          promises.push @rc.generateDecisionAidUserOptionPropertiesHash()

      @$q.all(promises).then (resolvedPromises) =>
        @Auth.decisionAidFound @decisionAid, data.meta.pages, @decisionAidUser
        # do some special stuff for traditional decision aids by ordering
        if @decisionAid.decision_aid_type is 'traditional' 
          @rc.setupTraditionalUserProperties()

        @$scope.$emit 'dcida.percentageCompletedUpdate', {checkNextPage: true}

        # finally done, set loading to false
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    ),
    ((error) =>
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      @noDecisionAidFound = true
    )

  generateOptionPropertyHash: () ->
    @optionPropertyHash = {}

    @_.each @optionProperties, (op) =>
      @optionPropertyHash[op.property_id] = {} if !@optionPropertyHash[op.property_id]?
      @optionPropertyHash[op.property_id][op.option_id] = op


  getSubDecisionChoice: () ->
    d = @$q.defer()
    @DecisionAidUserSubDecisionChoice.findBySubDecision(@decisionAidUser.id, @subDecisionId).then (data) =>
      if data
        @subDecisionChoice = new @DecisionAidUserSubDecisionChoice(data.decision_aid_user_sub_decision_choice)
      else
        @subDecisionChoice = new @DecisionAidUserSubDecisionChoice
        @subDecisionChoice.sub_decision_id = @subDecisionId
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  moreInfo: (property) ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/decision_aid/_results_more_info.html"
      controller: "ResultsMoreInfoCtrl"
      size: 'lg'
      resolve:
        options: () =>
          property: property
          options: @options
          optionProperties: @_.toArray(@optionPropertyHash[property.id])
    )

  shiftVisibleOptionsRight: () ->
    if @optionStartIndex < @rc.options.length - 3
      @optionStartIndex += 1
      @rc.visibleOptions = @rc.options.slice(@optionStartIndex, @optionStartIndex + 3)

  shiftVisibleOptionsLeft: () ->
    if @optionStartIndex > 0
      @optionStartIndex -= 1
      @rc.visibleOptions = @rc.options.slice(@optionStartIndex, @optionStartIndex + 3)

  setPropertyRowHeight: (index) ->
    row = jQuery("#results-row-#{index}")
    tds = row.find("td")
    maxHeight = Math.max.apply(null, @_.map(tds, (td) -> 
      jQuery(td).height()))
    maxHeight

  getNumber: (num) ->
    a = new Array(num)
    return a

  selectOption: (option) ->
    if option is "unsure"
      @subDecisionChoice.option_id = -1
    else
      @subDecisionChoice.option_id = option.id

  submitNext: () ->
    if @subDecisionChoice.option_id
      promises = []
      if @subDecisionChoice.id 
        promises.push @subDecisionChoice.$update({decision_aid_user_id: @decisionAidUser.id})
      else 
        promises.push @subDecisionChoice.$save({decision_aid_user_id: @decisionAidUser.id})

      if @decisionAid.decision_aid_type is "standard"
        promises.push @rc.submitUserOptionProperties()

      @$q.all(promises).then (promiseValues) =>
        # check whether we need to go through a second decision or not
        # if so, go to next my_choice
        # else, go to quiz
        if promiseValues[0].$metadata and promiseValues[0].$metadata.next_decision
          @$state.go 'decisionAidResults', {slug: @decisionAidSlug, sub_decision_order: promiseValues[0].$metadata.next_decision.sub_decision_order}
        else
          if @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
            @$state.go 'decisionAidPropertiesPostBestWorst', {slug: @decisionAidSlug}
          else if @decisionAid.quiz_questions_count == 0
            @$state.go 'decisionAidSummary', {slug: @decisionAidSlug}
          else
            @$state.go 'decisionAidQuiz', {slug: @decisionAidSlug}
      , (error) =>
        console.log error
    else
      @Confirm.warning
        message: 'Warning'
        messageSub: 'You can\'t procede until you have selected an option using the checkboxes'

  prevLink: () ->
    if @subDecisionOrder > 1
      @$state.go 'decisionAidResults', {slug: @decisionAidSlug, sub_decision_order: @subDecisionOrder - 1}
    else
      ps = @rc.prevState()
      params = {slug: @decisionAidSlug, back: true}
      if ps.params
        @_.extend(params, ps.params)
      @$state.go ps.stateName, params


module.controller 'DecisionAidResultsCtrl', DecisionAidResultsCtrl

