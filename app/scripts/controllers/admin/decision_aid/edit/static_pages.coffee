'use strict'

module = angular.module('dcida20App')

class DecisionAidEditStaticPagesCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'AdminTabHelper', '$uibModal', 'StaticPage', 'Sortable', 'Confirm', 'ErrorHandler', '_', '$window']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @AdminTabHelper, @$uibModal, @StaticPage, @Sortable, @Confirm, @ErrorHandler, @_, @$window) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @loading = true

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @extraInfoVisible = false

    @getStaticPages()

  getStaticPages: () ->
    @StaticPage.query {decision_aid_id: @$stateParams.decisionAidId}, (staticPages) =>
      @staticPages = staticPages
      #@_.each @staticPages, (p) =>
        #p.url = window.location.origin + "/#/decision_aid/#{@decisionAid.slug}/static_page?static_page_slug=#{p.page_slug}"
      @loading = false

  onSort: (staticPage, partFrom, partTo, indexFrom, indexTo) ->
    if staticPage and staticPage.static_page_order isnt indexTo + 1
      staticPage.static_page_order = indexTo + 1
      @Sortable.reorderItem(staticPage, @staticPages, 'static_page_order')

  deleteStaticPage: (page) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this static page?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      page.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @$state.go("decisionAidShow.staticPages", {decisionAidId: @$stateParams.decisionAidId})
        @Sortable.finishItemDeletion(page, @staticPages, 'static_page_order')
      ), (
        (error) => @handleError(error)
      )

  handleError: () ->
    console.log "Handled error"

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))

module.controller 'DecisionAidEditStaticPagesCtrl', DecisionAidEditStaticPagesCtrl

