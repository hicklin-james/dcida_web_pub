'use strict'

module = angular.module('dcida20App')

class DecisionAidStaticPageCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAidHome', 'moment', 'Auth', 'StaticPage', '_', 'NavBroadcastService', 'StateChangeRequested']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAidHome, @moment, @Auth, @StaticPage, @_, @NavBroadcastService, @StateChangeRequested) ->
    @$scope.ctrl = @

    @decisionAidSlug = @$stateParams.slug
    @staticPageSlug = @$stateParams.static_page_slug
    
    @decisionAid = null
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

    @$scope.$on 'decisionAidInvalid', () =>
      #console.log("YOLO!")
      @invalidDecisionAid()

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      if @modalInstance
        @modalInstance.dismiss()

    @DecisionAidHome.staticPage(@decisionAidSlug, @staticPageSlug).then ((data) =>
      @decisionAid = data.decision_aid
      @staticPage = data.decision_aid.static_page
      if !@staticPage
        @noStaticPageFound = true

      @decisionAidUser = data.meta.decision_aid_user
      @Auth.decisionAidFound @decisionAid, data.meta.pages, @decisionAidUser

      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      @loadedFlag = true
    ),
    ((error) =>
      @noDecisionAidFound = true
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    )

  invalidDecisionAid: () ->
    @decisionAid = null
    @NavBroadcastService.emitLoadingToRoot(false, @$scope)

  saveIfNewPageSubmission: () ->
    d = @$q.defer()

    if !@basicPageSubmissions[@currentPage.id]
      bps = new @BasicPageSubmission
      bps.intro_page_id = @currentPage.id
      bps.$save {decision_aid_user_id: @decisionAidUser.id}, (bps) =>
        @basicPageSubmissions[@currentPage.id] = bps
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

module.controller 'DecisionAidStaticPageCtrl', DecisionAidStaticPageCtrl

