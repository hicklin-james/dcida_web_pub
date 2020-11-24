'use strict'

module = angular.module('dcida20App')

class DecisionAidBestWorstCtrl
  @$inject: ['$scope', '$state', '$location', '$stateParams', 'DecisionAidHome', 'moment', 'Auth', '_', 'DecisionAidUserBwQuestionSetResponse', 'NavBroadcastService']
  constructor: (@$scope, @$state, @$location, @$stateParams, @DecisionAidHome, @moment, @Auth, @_, @DecisionAidUserBwQuestionSetResponse, @NavBroadcastService) ->
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @decisionAid = null
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    #console.log @$stateParams
    @currentQuestionSet = parseInt(@$stateParams.current_question_set)

    @DecisionAidHome.bw(@decisionAidSlug, @currentQuestionSet).then ((data) =>
      @decisionAid = data.decision_aid
      if @currentQuestionSet <= 0 || @currentQuestionSet > @decisionAid.bw_question_set_count
        @currentQuestionSet = null

      @decisionAidUser = data.meta.decision_aid_user
      @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)
      if @currentQuestionSet
        @bwQuestionSetResponse = data.decision_aid.bw_question_set_response
        @propertyLevels = data.decision_aid.bw_question_set_response.property_levels
        @DecisionAidUserBwQuestionSetResponse.findByQuestionSet(@currentQuestionSet, @decisionAidUser).then (r) =>
          if r and r.decision_aid_user_bw_question_set_response
            @decisionAidUserBwQuestionSetResponse = new @DecisionAidUserBwQuestionSetResponse r.decision_aid_user_bw_question_set_response
            # reset best and worst values if shown question set response is new or different
            if r.decision_aid_user_bw_question_set_response.bw_question_set_response_id isnt @bwQuestionSetResponse.id
              @decisionAidUserBwQuestionSetResponse.bw_question_set_response_id = @bwQuestionSetResponse.id
              @decisionAidUserBwQuestionSetResponse.worst_property_level_id = null
              @decisionAidUserBwQuestionSetResponse.best_property_level_id = null
          else
            @decisionAidUserBwQuestionSetResponse = new @DecisionAidUserBwQuestionSetResponse
            @decisionAidUserBwQuestionSetResponse.bw_question_set_response_id = @bwQuestionSetResponse.id
            @decisionAidUserBwQuestionSetResponse.question_set = @currentQuestionSet

          @percentageCompleted()
          @NavBroadcastService.emitLoadingToRoot(false, @$scope)
          @loadingComplete = true
        , (error) =>
          @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      else
        @percentageCompleted()
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    ),
    ((error) =>
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      @noDecisionAidFound = true
    )

  setPropertyLevel: (level, attr) ->
    otherAttr = if attr is "best" then "worst" else "best"
    if @decisionAidUserBwQuestionSetResponse["#{otherAttr}_property_level_id"] isnt level.id
      @decisionAidUserBwQuestionSetResponse["#{attr}_property_level_id"] = level.id

  saveUserSetResponse: () ->
    if !@decisionAidUserBwQuestionSetResponse.id
      @decisionAidUserBwQuestionSetResponse.$save({decision_aid_user_id: @decisionAidUser.id},
        ((qsr) =>
          @percentageCompleted()
          @determineNextState()
        ), ((error) =>
          console.log error
        ))
    else
      @decisionAidUserBwQuestionSetResponse.$update({decision_aid_user_id: @decisionAidUser.id},
        ((qsr) =>
          @percentageCompleted()
          @determineNextState()
        ), ((error) =>
          console.log error
        ))

  percentageCompleted: () ->
    r = @decisionAidUser.decision_aid_user_bw_question_set_responses_count / @decisionAid.bw_question_set_responses_count
    data = 
      percentageCompleted: r
    @$scope.$emit 'dcida.percentageCompletedUpdate', data

  determineNextState: () ->
    if @currentQuestionSet is @decisionAid.bw_question_set_count
      if @decisionAid.decision_aid_type is "best_worst" or @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
        @$state.go "decisionAidResults", {slug: @decisionAidSlug}
      else if @decisionAid.decision_aid_type is "best_worst_no_results"
        if @decisionAid.quiz_questions_count == 0
          @$state.go "decisionAidSummary", {slug: @decisionAidSlug}
        else
          @$state.go "decisionAidQuiz", {slug: @decisionAidSlug}
    else
      nextQuestionSet = @currentQuestionSet + 1
      @$state.go 'decisionAidBestWorst', {slug: @decisionAidSlug, current_question_set: nextQuestionSet}

  submitNext: () ->
    if @currentQuestionSet && @currentQuestionSet >= 1 && @decisionAidUserBwQuestionSetResponse.best_property_level_id && @decisionAidUserBwQuestionSetResponse.worst_property_level_id
      @saveUserSetResponse()    
    else
      @currentQuestionSet = 1
      @$state.go 'decisionAidBestWorst', {slug: @decisionAidSlug, current_question_set: @currentQuestionSet++}

  prevLink: () ->
    if @currentQuestionSet && @currentQuestionSet > 0
      prevQuestionSet = @currentQuestionSet - 1
      @$state.go 'decisionAidBestWorst', {slug: @decisionAidSlug, current_question_set: prevQuestionSet}
    else
      if @decisionAid.demographic_questions_count == 0
        @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: true})
      else
        @$state.go "decisionAidAbout", {slug: @decisionAidSlug, back: true}



module.controller 'DecisionAidBestWorstCtrl', DecisionAidBestWorstCtrl

