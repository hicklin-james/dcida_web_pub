'use strict'

module = angular.module('dcida20App')

class DecisionAidQuizCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'Auth', 'DecisionAidHome', 'Question', 'DecisionAidUserResponse', 'QuestionControl', 'NavBroadcastService', '$ngSilentLocation', '$window', '$location', '$timeout', 'WEBAPP_ENDPOINT', 'StateChangeRequested']
  constructor: (@$scope, @$state, @$stateParams, @Auth, @DecisionAidHome, @Question, @DecisionAidUserResponse, @QuestionControl, @NavBroadcastService,  @ngSilentLocation, @$window, @$location, @$timeout, @WEBAPP_ENDPOINT, @StateChangeRequested) ->
    @$scope.ctrl = @

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

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

    @DecisionAidHome.quiz(@decisionAidSlug, currQuestionPageId, back, first).then (data) =>
      @decisionAid = data.decision_aid
      @decisionAidUser = data.meta.decision_aid_user

      @question_page = data.decision_aid.question_page
      @questions = if @question_page then @question_page.questions else null

      if @question_page
        @ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/quiz?curr_question_page_id=#{@question_page.id}")
      else
        @$state.go("decisionAidQuiz", {slug: @decisionAidSlug, back: false, first: true})
        return

      @DecisionAidUserResponse.query {decision_aid_user_id: @decisionAidUser.id, question_type: @questionType}, (decisionAidUserResponses) =>
        @qc = new @QuestionControl(@decisionAid, @decisionAidUser, decisionAidUserResponses, @$stateParams, "quiz", "quiz", @$scope)
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
    @goToSummary(p)

  prevLink: () ->
    r = @qc.prevAction()
    # console.log r
    # console.log @question_page
    if r is "gobackwithinsection"
      @$state.go 'decisionAidQuiz', {slug: @decisionAidSlug, back: true, curr_question_page_id: @question_page.id, first: false}
    else if r is "gobacksection"
      if @decisionAid.decision_aid_type is "best_worst_no_results"
        @$state.go('decisionAidBestWorst', {slug: @decisionAidSlug, current_question_set: @decisionAid.bw_question_set_count, back: true})
      else if @decisionAid.decision_aid_type is "dce_no_results"
        @$state.go("decisionAidDce", {slug: @decisionAidSlug, current_question_set: @decisionAid.dce_question_set_count, back: true})
      else if @decisionAid.decision_aid_type is "traditional_no_results"
        @$state.go("decisionAidTraditionalProperties", {slug: @decisionAidSlug, back: true})
      else if @decisionAid.decision_aid_type is "decide"
        @$state.go("decisionAidPropertiesDecide", {slug: @decisionAidSlug, back: true})
      else if @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
          @$state.go "decisionAidPropertiesPostBestWorst", {slug: @decisionAidSlug, back: true}
      else if @decisionAid.decision_aid_type is "risk_calculator"
        if @decisionAid.demographic_questions_count > 0
          @$state.go "decisionAidAbout", {slug: @decisionAidSlug, back: true}
        else
          @$state.go "decisionAidIntro", {slug: @decisionAidSlug, back: true}
      else
        @$state.go('decisionAidResults', {slug: @decisionAidSlug, sub_decision_order: @decisionAidUser.decision_aid_user_sub_decision_choices_count, back: true}) if r

  goToSummary: (p, params) ->
    if p is null
      return
    else if p is "first"
      @$state.go 'decisionAidQuiz', {slug: @decisionAidSlug, first: true}
    else
      params = {} if !params
      params.slug = @decisionAidSlug
      p.then (d) =>
        if d and d.url_to_skip_to
          uriTarget = parseUri(d.url_to_skip_to)
          if @WEBAPP_ENDPOINT.indexOf(uriTarget.host) >= 0
            @$location.url(uriTarget.anchor)
          else
            @$window.location = d.url_to_skip_to
          return

        if d.next_question_page == "next"
           @$state.go "decisionAidQuiz", {slug: @decisionAidSlug, curr_question_page_id: d.next_question_page_id, first: false, back: false}
        else if d.next_question_page == "finished"
          @$state.go "decisionAidSummary", params

  selectResponse: (question, response) ->
    p = @qc.selectResponse(question, response)
    @goToSummary(p)

  selectOption: (question, option) ->
    p = @qc.selectOption(question, option)
    @goToSummary(p)

  selectYesNoResponse: (question, event) ->
    @qc.selectYesNoResponse(question)
    event.stopPropagation()

module.controller 'DecisionAidQuizCtrl', DecisionAidQuizCtrl

