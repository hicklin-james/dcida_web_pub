'use strict'

module = angular.module('dcida20App')

class DecisionAidSummaryCtrl
  @$inject: ['$scope', '$window', 'Confirm', '$compile', '$state', '$timeout', '$stateParams', 'Question', 'DecisionAidUserResponse', 'DecisionAidUserSubDecisionChoice', 'DecisionAidHome', 'DecisionAidUser', 'DecisionAidUserProperty', 'DecisionAidUserOptionProperty', 'moment', 'Auth', '_', '$uibModal', '$document', 'Util', '$q', 'API_PUBLIC', 'WEBAPP_ENDPOINT', '$location', 'NavBroadcastService', 'StateChangeRequested']
  constructor: (@$scope, @$window, @Confirm, @$compile, @$state, @$timeout, @$stateParams, @Question, @DecisionAidUserResponse, @DecisionAidUserSubDecisionChoice, @DecisionAidHome, @DecisionAidUser, @DecisionAidUserProperty, @DecisionAidUserOptionProperty, @moment, @Auth, @_, @$uibModal, @$document, @Util, @$q, @API_PUBLIC, @WEBAPP_ENDPOINT, @$location, @NavBroadcastService, @StateChangeRequested) ->
    @$scope.ctrl = @

    @summary_address = null

    @$scope.$on 'decisionAidInvalid', () =>
      @decisionAid = null
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)
    @summaryEmailPromise = null

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      if @summaryEmailPromise
        @$timeout.cancel(@summaryEmailPromise)

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null

    @DecisionAidHome.summary(@decisionAidSlug).then ((data) =>
      @decisionAid = data.decision_aid
      @decisionAidUser = new @DecisionAidUser data.meta.decision_aid_user
      @subDecisions = data.decision_aid.sub_decisions
      @summaryPanels = data.decision_aid.summary_panels
      @options = data.decision_aid.options
      @resultMatchOption = data.meta.result_match_option
      @groupedOptions = @_.groupBy @options, 'sub_decision_id'
      @indexedOptions = @_.indexBy @options, 'id'
      @questions = data.decision_aid.questions
      @indexedQuestions = @_.indexBy @Question.flattenQuestions(@questions), 'id'
      @questionResponseHash = {}
      @_.each @questions, (q) =>
        #q.has_correct_answer = @_.some q.question_responses, (qr) => qr.is_correct_value is true
        if !@questionResponseHash[q.id]?
          @questionResponseHash[q.id] = @_.indexBy q.question_responses, (qr) => qr.id

      @selectedOptions = {}
      @_.each @groupedOptions, (os) =>

      @properties = data.decision_aid.properties
      # create the option property hash
      @optionPropertyHash = {}
      @optionProperties = data.decision_aid.option_properties
      @_.each data.decision_aid.option_properties, (op) =>
        if !@optionPropertyHash[op.property_id]?
          @optionPropertyHash[op.property_id] = {}
        @optionPropertyHash[op.property_id][op.option_id] = op



      oids = @_.map(@options, (o) -> o.id)

      p1 = @DecisionAidUserOptionProperty.query {decision_aid_user_id: @decisionAidUser.id, 'option_ids[]': oids}

      p2 = @DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id}

      p3 = @DecisionAidUserResponse.query {decision_aid_user_id: @decisionAidUser.id}

      p4 = @DecisionAidUserSubDecisionChoice.query {decision_aid_user_id: @decisionAidUser.id}

      promises = [p1.$promise, p2.$promise, p3.$promise, p4.$promise]

      @$q.all(promises).then (resolvedPromises) =>
        @createDauopsHash(resolvedPromises[0])
        @userProps = resolvedPromises[1]
        @indexedUserProps = @_.indexBy @userProps, "property_id"
        if @decisionAid.decision_aid_type is "traditional" or @decisionAid.decision_aid_type is "best_worst" or @decisionAid.decision_aid_type is "best_worst_no_results"
          @groupedProperties = @_.groupBy(@properties, (p) => @indexedUserProps[p.id]?.traditional_value)
          @sortedProperties = @_(@properties).chain()
            .sortBy('property_order')
            .sortBy((p) => if @indexedUserProps[p.id] then -@indexedUserProps[p.id].traditional_value else null)
            .value()
          
          @propertyData = @_.map @sortedProperties, (p, i) =>
            v = if @indexedUserProps[p.id]?.traditional_value then @indexedUserProps[p.id].traditional_value else 0
            {
              value: v,
              label: if p.short_label then p.short_label else p.title
            }
        else if @decisionAid.decision_aid_type is "dce"
          @sortedProperties = @_.sortBy @properties, 'property_order'
        else if @decisionAid.decision_aid_type is "treatment_rankings"
          @sortedProperties = @_.sortBy(@properties, (p) => 
            if @indexedUserProps[p.id]
              @indexedUserProps[p.id].weight
            else
              -1
          ).reverse()
          @filteredSortedProperties = @_.filter @sortedProperties, (p) =>  @indexedUserProps[p.id]?.weight
          @_.each @filteredSortedProperties, (p) =>
            @indexedUserProps[p.id].star_url = @WEBAPP_ENDPOINT + "/" + "images/stars/#{@indexedUserProps[p.id].weight}.png"
          @propertyData = @_.map @filteredSortedProperties, (p, i) =>
            v = if @indexedUserProps[p.id].weight then @indexedUserProps[p.id].weight else 0
            {
              value: v,
              label: p.title
            }
        @userResponses = @_.indexBy(resolvedPromises[2], 'question_id')
        @subDecisionChoiceHash = @_.indexBy resolvedPromises[3], 'option_id'
        @subDecisionChoiceHashIndexedBySubDecisionId = @_.indexBy resolvedPromises[3], 'sub_decision_id'
        @Auth.decisionAidFound @decisionAid, data.meta.pages, @decisionAidUser

        currentTreatmentQuestion = @_.find @questions, (q) => q.question_response_type is "current_treatment"
        if currentTreatmentQuestion
          @currentTreatment = @userResponses[currentTreatmentQuestion.id].option_id

        @$scope.$emit 'dcida.percentageCompletedUpdate', {checkNextPage: true}
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)
        
        # if @decisionAid.include_admin_summary_email
        #   @summaryEmailPromise = @$timeout () =>
        #     @generatePdf()
        #   , 5000

      , (error) =>
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)

    ),
    ((error) =>
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      @noDecisionAidFound = true
    )

  createDauopsHash: (dauops) ->
    @askedForHelp = dauops.length > 0

    missingProps = @DecisionAidUserOptionProperty.createMissingOptionProperties(dauops, @optionProperties, @decisionAidUser)
    combinedProps = dauops.concat missingProps

    @dauopsHash = {}
    @_.each combinedProps, (op) =>
      if !@dauopsHash[op.property_id]?
        @dauopsHash[op.property_id] = {}
      @dauopsHash[op.property_id][op.option_id] = op

  setPropertyRowHeight: (index) =>
    row = jQuery("#results-row-#{index}")
    tds = row.find("td")
    maxHeight = Math.max.apply(null, @_.map(tds, (td) -> 
      jQuery(td).height()))
    maxHeight

  generatePdf: () ->
    # now I need to render this element outside the dom with letter sized width and height
    #info = angular.element('#offscreen-content-wrapper').html()
    #console.log info
    #return null
    info = angular.element('#summary-content').html()
    angular.element('#offscreen-content-wrapper').html(info)
    @$timeout () =>
      #@$window.dispatchEvent(new Event("resize"));
      #realInfo = angular.element('#offscreen-content-wrapper').html()
      @DecisionAidHome.generatePdf(@decisionAidSlug, info, false)
    , 2000

  sendPdfEmail: () ->
    info = angular.element('#summary-content').html()
    angular.element('#offscreen-content-wrapper').html(info)
    @$timeout () =>
      #@$window.dispatchEvent(new Event("resize"));
      #realInfo = angular.element('#offscreen-content-wrapper').html()
      if @summary_address
        @DecisionAidHome.generatePdf(@decisionAidSlug, info, false, @summary_address).then () =>
          @Confirm.alert(
            message: 'Success!'
            messageSub: "You should recieve an email shortly with your summary PDF attached"
            headerClass: 'text-success'
            buttonType: 'default'
          )
    , 2000

  downloadPdf: () ->
    @startingPdfDownload = true
    info = angular.element('#summary-content').html()
    angular.element('#offscreen-content-wrapper').html(info)
    @$timeout () =>
      #@$window.dispatchEvent(new Event("resize"));
      #realInfo = angular.element('#offscreen-content-wrapper').html()
      @DecisionAidHome.openPdf(@decisionAidSlug, info, false).then (downloadItem) =>
        @startingPdfDownload = false
        file_path = @API_PUBLIC + "/" + downloadItem.download_item.file_location
        @Confirm.downloadReady(
          downloadLink: file_path
          downloadName: "Your Summary Page"
        )
      , (error) =>
        @startingPdfDownload = false
    , 2000
      #@$window.open(file_path)

  submitNext: () ->
    if @decisionAid.open_summary_link_in_new_tab
      @$window.open(@decisionAid.summary_link_to_url)
    else
      @$window.location = @decisionAid.summary_link_to_url
    true

  prevLink: () ->
    if @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
      if @decisionAid.quiz_questions_count > 0
        @$state.go "decisionAidQuiz", {slug: @decisionAidSlug, back: true}
      else
        @$state.go "decisionAidPropertiesPostBestWorst", {slug: @decisionAidSlug, back: true}
    else if @decisionAid.quiz_questions_count == 0
      if @decisionAid.decision_aid_type is "best_worst_no_results"
        @$state.go('decisionAidBestWorst', {slug: @decisionAidSlug, current_question_set: @decisionAid.bw_question_set_count, back: true})
      if @decisionAid.decision_aid_type is "decide"
        @$state.go('decisionAidPropertiesDecide', {slug: @decisionAidSlug, back: true})
      else if @decisionAid.decision_aid_type is "dce_no_results"
        @$state.go("decisionAidDce", {slug: @decisionAidSlug, current_question_set: @decisionAid.dce_question_set_count, back: true})
      else if @decisionAid.decision_aid_type is "risk_calculator"
        if @decisionAid.demographic_questions_count == 0
          @$state.go 'decisionAidIntro', {slug: @decisionAidSlug, back: true}
        else
          @$state.go 'decisionAidAbout', {slug: @decisionAidSlug, back: true}
      else
        @$state.go('decisionAidResults', {slug: @decisionAidSlug, sub_decision_order: @decisionAidUser.decision_aid_user_sub_decision_choices_count, back: true})
    else
      @$state.go 'decisionAidQuiz', {slug: @decisionAidSlug, back: true}

module.controller 'DecisionAidSummaryCtrl', DecisionAidSummaryCtrl

