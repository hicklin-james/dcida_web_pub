'use strict'

module = angular.module('dcida20App')

class DecisionAidAboutCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'Auth', 'DecisionAidHome', 'Question', 'DecisionAidUserResponse', 'moment', '_', '$q', 'Confirm', '$ngSilentLocation', '$anchorScroll', 'QuestionControl', '$window', '$location', 'NavBroadcastService', '$timeout', 'WEBAPP_ENDPOINT', 'StateChangeRequested']
  constructor: (@$scope, @$state, @$stateParams, @Auth, @DecisionAidHome, @Question, @DecisionAidUserResponse, @moment, @_, @$q, @Confirm, @ngSilentLocation, @$anchorScroll, @QuestionControl, @$window, @$location, @NavBroadcastService, @$timeout, @WEBAPP_ENDPOINT, @StateChangeRequested) ->
    @$scope.ctrl = @

    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)
    
    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null

    currQuestionPageId = @$stateParams.curr_question_page_id
    back = @$stateParams.back
    first = @$stateParams.first
    if (!back and !first and !currQuestionPageId)
      first = true

    @$scope.$on 'decisionAidInvalid', () =>
      @decisionAid = null
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      
    if @$state.current and @$state.current.data and @$state.current.data.questionType
      @questionType = @$state.current.data.questionType

    @DecisionAidHome.about(@decisionAidSlug, currQuestionPageId, back, first).then (data) =>
      @decisionAid = data.decision_aid
      @decisionAidUser = data.meta.decision_aid_user

      @question_page = data.decision_aid.question_page
      @questions = if @question_page then @question_page.questions else null

      if @question_page
        @ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/about?curr_question_page_id=#{@question_page.id}")
      else
        @$state.go("decisionAidAbout", {slug: @decisionAidSlug, back: false, first: true})
        return
        #@ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/about")

      @DecisionAidUserResponse.query {decision_aid_user_id: @decisionAidUser.id, question_type: @questionType}, (decisionAidUserResponses) =>
        @qc = new @QuestionControl(@decisionAid, @decisionAidUser, decisionAidUserResponses, @$stateParams, "demographic", "about", @$scope)
        @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)

      , (error) =>
        @noDecisionAidFound = true
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)

    , (error) =>
      @noDecisionAidFound = true
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)

  submitNext: () ->
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    if !@$scope.$$phase
      @$scope.$digest()

    p = @qc.nextAction()
    @goToPreferenceElicitation(p)

  prevLink: () ->
    r = @qc.prevAction()
    if r is "gobacksection"
      @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: true, first: false})
    else if r is "gobackwithinsection"
      @$state.go 'decisionAidAbout', {slug: @decisionAidSlug, back: true, curr_question_page_id: @question_page.id, first: false}

  goToPreferenceElicitation: (p) ->
    #console.log "STATE SHOULD START TO CHANGE"
    if p is null
      return
    else if p is "first"
      @$state.go 'decisionAidAbout', {slug: @decisionAidSlug, first: true, back: false}
    else
      p.then (d) =>
        if d and d.url_to_skip_to
          if d.skip_to is "other_section"
            @$scope.$emit "dcida.goToPage", d
          else
            uriTarget = parseUri(d.url_to_skip_to)
            if @WEBAPP_ENDPOINT.indexOf(uriTarget.host) >= 0
              @$location.url(uriTarget.anchor)
            else
              @$window.location = d.url_to_skip_to
    
          return

        if d.next_question_page == "next"
          @$state.go "decisionAidAbout", {slug: @decisionAidSlug, curr_question_page_id: d.next_question_page_id, first: false, back: false}
        else if d.next_question_page == "finished"
          if @decisionAid.decision_aid_type is 'dce' or @decisionAid.decision_aid_type is "dce_no_results"
            @$state.go "decisionAidDce", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'best_worst' or @decisionAid.decision_aid_type is 'best_worst_no_results' or @decisionAid.decision_aid_type is 'best_worst_with_prefs_after_choice'
            @$state.go "decisionAidBestWorst", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'traditional'
            @$state.go "decisionAidResults", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'standard_enhanced'
            @$state.go "decisionAidPropertiesEnhanced", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'decide'
            @$state.go "decisionAidPropertiesDecide", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'traditional_no_results'
            @$state.go "decisionAidTraditionalProperties", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is "risk_calculator"
            if @decisionAid.quiz_questions_count > 0
              @$state.go "decisionAidQuiz", {slug: @decisionAidSlug}
            else
              @$state.go "decisionAidSummary", {slug: @decisionAidSlug}
          else
            @$state.go "decisionAidProperties", {slug: @decisionAidSlug}
     
  selectResponse: (question, response) ->
    p = @qc.selectResponse(question, response)
    @goToPreferenceElicitation(p)

  selectOption: (question, option) ->
    p = @qc.selectOption(question, option)
    @goToPreferenceElicitation(p)

  selectYesNoResponse: (question, event) ->
    @qc.selectYesNoResponse(question)
    event.stopPropagation()

module.controller 'DecisionAidAboutCtrl', DecisionAidAboutCtrl

