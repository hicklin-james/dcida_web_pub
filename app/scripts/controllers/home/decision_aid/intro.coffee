'use strict'

module = angular.module('dcida20App')

class DecisionAidIntroCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAidHome', 'moment', 'Auth', '$uibModal', '_', '$ngSilentLocation', 'BasicPageSubmission', '$q', '$anchorScroll', 'NavBroadcastService', '$timeout', 'StateChangeRequested']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAidHome, @moment, @Auth, @$uibModal, @_, @ngSilentLocation, @BasicPageSubmission, @$q, @$anchorScroll, @NavBroadcastService, @$timeout, @StateChangeRequested) ->
    @$scope.ctrl = @

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

    @currentIntroPageOrder = @$stateParams.curr_intro_page_order
    back = @$stateParams.back
    first = @$stateParams.first

    if !@currentIntroPageOrder and !back
      first = true

    # if @$stateParams.page_id or @$stateParams.back
    #   if @$stateParams.page_id
    #     @currentPage = @introPagesById[@$stateParams.page_id]
    #   else
    #     @currentPage = @introPages[@introPages.length-1]
    #     @ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/intro?page_id=#{@currentPage.id}")

    @$scope.$on 'decisionAidInvalid', () =>
      #console.log("YOLO!")
      @invalidDecisionAid()

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      if @modalInstance
        @modalInstance.dismiss()

    @DecisionAidHome.intro(@decisionAidSlug, @currentIntroPageOrder, back, first).then ((data) =>
      @decisionAid = data.decision_aid
      @currentPage = @decisionAid.intro_page

      if @currentPage
        @ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/intro?curr_intro_page_order=#{@currentPage.intro_page_order}")
      else
        console.error("No introPage with intro_page_order <#{@currentIntroPageOrder}>, redirecting to start of intro pages.")
        @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: false, first: true})
        return

      @decisionAidUser = data.meta.decision_aid_user

      @BasicPageSubmission.query {decision_aid_user_id: @decisionAidUser.id, intro_page_id: @currentPage.id}, (submissions) =>
        if submissions.length > 0
          @basicPageSubmission = submissions[0]

        @Auth.decisionAidFound @decisionAid, data.meta.pages, @decisionAidUser
        
        if @decisionAid.has_intro_popup and @currentPage.intro_page_order is 1 # and data.meta.is_new_user
          @modalInstance = @$uibModal.open(
            templateUrl: "/views/home/decision_aid/intro_popup.html"
            controller: "IntroPopupCtrl"
            size: 'lg'
            resolve:
              options: () =>
                intro_info: @decisionAid.injected_intro_popup_information_published
          )
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)

      , (error) =>
        @invalidDecisionAid()
    ),
    ((error) =>
      @invalidDecisionAid()
    )

  invalidDecisionAid: () ->
    @noDecisionAidFound =  true
    @decisionAid = null
    @NavBroadcastService.emitLoadingToRoot(false, @$scope)

  saveIfNewPageSubmission: () ->
    d = @$q.defer()

    if !@basicPageSubmission
      bps = new @BasicPageSubmission
      bps.intro_page_id = @currentPage.id
      bps.$save {decision_aid_user_id: @decisionAidUser.id}, (bps) =>
        @basicPageSubmission = bps
        d.resolve()
      , (error) =>
        d.reject()
    else
      d.resolve()

    d.promise

  # percentageCompleted: () ->
  #   r = @_.toArray(@basicPageSubmissions).length / @introPages.length
  #   data = 
  #     percentageCompleted: r
  #   @$scope.$emit 'dcida.percentageCompletedUpdate', data

  scrollToTop: () ->
    @$anchorScroll()

  submitNext: () ->
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @saveIfNewPageSubmission().then () =>
      if @currentPage.intro_page_order is @decisionAid.intro_pages_count
        if @decisionAid.demographic_questions_count == 0
          if @decisionAid.decision_aid_type is 'dce' or @decisionAid.decision_aid_type is "dce_no_results"
            @$state.go "decisionAidDce", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'best_worst' or @decisionAid.decision_aid_type is 'best_worst_no_results'
            @$state.go "decisionAidBestWorst", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'traditional'
            @$state.go "decisionAidResults", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'standard_enhanced'
            @$state.go "decisionAidPropertiesEnhanced", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'decide'
            @$state.go "decisionAidPropertiesDecide", {slug: @decisionAidSlug}
          else if @decisionAid.decision_aid_type is 'risk_calculator'
            if @decisionAid.quiz_questions_count > 0
              @$state.go "decisionAidQuiz", {slug: @decisionAidSlug}
            else
              @$state.go "decisionAidSummary", {slug: @decisionAidSlug}
          else
            @$state.go "decisionAidProperties", {slug: @decisionAidSlug}
        else
          @$state.go 'decisionAidAbout', {slug: @decisionAidSlug}
      else
        nextPageOrder = @currentPage.intro_page_order + 1
        @$state.go("decisionAidIntro", {slug: @decisionAidSlug, curr_intro_page_order: nextPageOrder, back: false, first: false})

  prevLink: () ->
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    prevOrder = @currentPage.intro_page_order - 1
    if prevOrder > 0
      @$state.go("decisionAidIntro", {slug: @decisionAidSlug, curr_intro_page_order: prevOrder, back: false, first: false})

module.controller 'DecisionAidIntroCtrl', DecisionAidIntroCtrl

