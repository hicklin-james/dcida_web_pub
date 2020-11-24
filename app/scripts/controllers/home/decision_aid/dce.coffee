'use strict'

module = angular.module('dcida20App')

class DecisionAidDceCtrl
  @$inject: ['$scope', '$state', '$location', '$stateParams', 'DecisionAidHome', 'moment', 'Auth', '_', 'DecisionAidUserDceQuestionSetResponse', '$timeout', '$uibModal', 'Confirm', '$document', 'NavBroadcastService', '$translate', 'DceConditionalCtrl', 'DceStandardCtrl', 'DceOptOutCtrl', 'Util', 'StateChangeRequested']
  constructor: (@$scope, @$state, @$location, @$stateParams, @DecisionAidHome, @moment, @Auth, @_, @DecisionAidUserDceQuestionSetResponse, @$timeout, @$uibModal, @Confirm, @$document, @NavBroadcastService, @$translate, @DceConditionalCtrl, @DceStandardCtrl, @DceOptOutCtrl, @Util, @StateChangeRequested) ->
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @invalidDecisionAid()

    @delaySwitch = false

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)
    @letters = ["A", "B", "C", "D", "E", "F"] # we can assume there will be no more than this
    @currentQuestionSet = if @$stateParams.current_question_set? then parseInt(@$stateParams.current_question_set) else null
    
    @DecisionAidHome.dce(@decisionAidSlug, @currentQuestionSet).then ((data) =>
      @decisionAid = data.decision_aid
      if @currentQuestionSet && @currentQuestionSet <= 0 || @currentQuestionSet > @decisionAid.dce_question_set_count
        @currentQuestionSet = null

      @decisionAidUser = data.meta.decision_aid_user
      @dceQuestionSetResponses = angular.copy data.decision_aid.dce_question_set_responses
      @properties = data.decision_aid.properties

      @setupProperties()
      @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)

      @optOutOption = @_.find(@dceQuestionSetResponses, (dceqr) => dceqr.is_opt_out)
      if @optOutOption
        @dceQuestionSetResponses.shift()

      if @currentQuestionSet
        @DecisionAidUserDceQuestionSetResponse.findByQuestionSet(@currentQuestionSet, @decisionAidUser).then (r) =>
          if r and r.decision_aid_user_dce_question_set_response
            @userSetResponse = new @DecisionAidUserDceQuestionSetResponse(r.decision_aid_user_dce_question_set_response)
          else
            @userSetResponse = new @DecisionAidUserDceQuestionSetResponse
            @userSetResponse.decision_aid_user_id = @decisionAidUser.id
            @userSetResponse.question_set = @currentQuestionSet

          if @decisionAid.dce_type == "conditional"
            @dceController = new @DceConditionalCtrl(@$scope, @decisionAid, @decisionAidUser, @properties, @dceQuestionSetResponses, @userSetResponse)
          else if @decisionAid.dce_type is "normal"
            @dceController = new @DceStandardCtrl(@$scope, @decisionAid, @decisionAidUser, @properties, @dceQuestionSetResponses, @userSetResponse)
          else if @decisionAid.dce_type is "opt_out"
            @dceController = new @DceOptOutCtrl(@$scope, @decisionAid, @decisionAidUser, @properties, @dceQuestionSetResponses, @userSetResponse)

          @NavBroadcastService.emitLoadingToRoot(false, @$scope)
        , (error) =>
          @invalidDecisionAid()
      else
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    ),
    ((error) =>
      @invalidDecisionAid()
    )

  invalidDecisionAid: () ->
    @noDecisionAidFound =  true
    @decisionAid = null
    @NavBroadcastService.emitLoadingToRoot(false, @$scope)

  areAllAttributesSetForProperty: (prop) ->
    @_.all(@dceQuestionSetResponses, (qsr) => 
      prop.property_level_hash[qsr.property_level_hash[prop.id]]
    )

  # percentageCompleted: () ->
  #   r = @decisionAidUser.decision_aid_user_dce_question_set_responses_count / @decisionAid.dce_question_set_count 
  #   data = 
  #     percentageCompleted: r
  #   @$scope.$emit 'dcida.percentageCompletedUpdate', data

  selectQsr: (qsr) ->
    valid = @dceController.selectQsr(qsr)
    if valid and @decisionAid.properties_auto_submit and @dceController.shouldAutoSubmit()
      @submitNext()

  setOptionConfirmed: (val) =>
    allowed = @dceController.setOptionConfirmed(val)
    if allowed and @decisionAid.properties_auto_submit
      @submitNext()

  resetResponses: () ->
    @dceController.reset()
    @$document.duScrollTop(0, 300)

  setupProperties: () ->
    # order the properties based on design
    @orderProperties()

    # set level colors if enabled
    if @decisionAid.color_rows_based_on_attribute_levels
      @setupPropertyLevelColors()

    # index the propery levels for easy access
    @_.each @properties, (p) =>
      plevels = p.property_levels
      p.property_level_hash = @_.indexBy plevels, 'level_id'

  setupPropertyLevelColors: () ->
    r = new Rainbow()
    r.setSpectrum(@Util.rgbToHex(@decisionAid.dce_min_level_color), @Util.rgbToHex(@decisionAid.dce_max_level_color))
    @_.each @properties, (p) =>
      r.setNumberRange(1, p.property_levels.length)
      @_.each p.property_levels, (pl) =>
        #optOutFiltered = @_.filter(@dceQuestionSetResponses, (dqr) => !dqr.is_opt_out)
        #if !@_.all(optOutFiltered, (dqr) => dqr.property_level_hash[p.id] is optOutFiltered[0].property_level_hash[p.id])
        pl.color = {'background-color': '#' + r.colorAt(pl.level_id)}
        #pl.color ?= {'background-color': 'white'}

  orderProperties: () ->
    if @dceQuestionSetResponses && 
       @dceQuestionSetResponses.length > 1 && 
       @dceQuestionSetResponses[1].property_level_hash.orders &&
       @_.all(@properties, ((p) => @dceQuestionSetResponses[1].property_level_hash.orders[p.id]))
        
      @properties = @_.sortBy(@properties, ((p) => @dceQuestionSetResponses[1].property_level_hash.orders[p.id]))
  
  determineNextState: () ->
    if @currentQuestionSet is @decisionAid.dce_question_set_count
      if @decisionAid.decision_aid_type is "dce_no_results"
        if @decisionAid.quiz_questions_count is 0
          @$state.go "decisionAidSummary", {slug: @decisionAidSlug}
        else
          @$state.go "decisionAidQuiz", {slug: @decisionAidSlug}
      else
        @$state.go "decisionAidResults", {slug: @decisionAidSlug}
    else
      nextQuestionSet = @currentQuestionSet + 1
      @$state.go 'decisionAidDce', {slug: @decisionAidSlug, current_question_set: nextQuestionSet}
  
  saveUserSetResponse: () ->
    if !@userSetResponse.id
      @userSetResponse.$save({decision_aid_user_id: @decisionAidUser.id},
        ((qsr) =>
          #@percentageCompleted()
          @determineNextState()
        ), ((error) =>
          console.log error
        ))
    else
      @userSetResponse.$update({decision_aid_user_id: @decisionAidUser.id},
        ((qsr) =>
          #@percentageCompleted()
          @determineNextState()
        ), ((error) =>
          console.log error
        ))

  moreInfo: (property) ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/decision_aid/dce_property_popup.html"
      controller: "DcePropertiesPopupCtrl"
      size: 'lg'
      resolve:
        options: () =>
          property_title: property.title,
          property_long_about: property.injected_long_about_published
    )

  submitNext: () ->
    switcher = (if @dceController then @dceController.submit() else "readyToSave")
    switch switcher
      when "firstDecisionCompleted"
        @$document.duScrollTop(0, 300)
        return
      when "invalid"
        @$translate(['OOPS', 'MUST-SELECT-DCE-OPTION']).then (translations) =>
          @Confirm.warning(
            message: translations['OOPS'],
            messageSub: translations['MUST-SELECT-DCE-OPTION'],
            buttonType: "default"
          )
      when "readyToSave"
        if @currentQuestionSet && @currentQuestionSet >= 1
          @saveUserSetResponse()    
        else
          @currentQuestionSet = 1
          @$state.go 'decisionAidDce', {slug: @decisionAidSlug, current_question_set: @currentQuestionSet++}

  prevLink: () ->
    if @currentQuestionSet && @currentQuestionSet > 0
      prevQuestionSet = @currentQuestionSet - 1
      @$state.go 'decisionAidDce', {slug: @decisionAidSlug, current_question_set: prevQuestionSet}
    else
      if @decisionAid.demographic_questions_count == 0
        @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: true})
      else
        @$state.go "decisionAidAbout", {slug: @decisionAidSlug, back: true}



module.controller 'DecisionAidDceCtrl', DecisionAidDceCtrl

