'use strict'

module = angular.module('dcida20App')


class DecisionAidEditSummaryCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'Confirm', 'AdminTabHelper', 'SummaryPanel', 'Sortable', 'ErrorHandler', 'SummaryPage', '$q', '_']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @Confirm, @AdminTabHelper, @SummaryPanel, @Sortable, @ErrorHandler, @SummaryPage, @$q, @_) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @saveSuccess = false

    # @$scope.$watch 'ctrl.currentlyEditingSummaryPage.include_admin_summary_email', (nv, ov) =>
    #   if ov
    #     @saveSummaryPage()

    # @$scope.$watch 'ctrl.currentlyEditingSummaryPage.is_primary', (nv, ov) =>
    #   if ov
    #     @primarySummaryPageChanged()

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @loading = true
    p1 =  @SummaryPanel.query({decision_aid_id: @$stateParams.decisionAidId}).$promise
    p2 = @SummaryPage.query({decision_aid_id: @$stateParams.decisionAidId}).$promise

    promises = [p1, p2]

    @$q.all(promises).then (ps) =>
      @summaryPanels = ps[0]
      @indexedSummaryPanels = @_.groupBy ps[0], "summary_page_id"
      @summaryPages = ps[1]
      @mapSummaryPanelsToPages()

      @currentlyEditingSummaryPage = @summaryPages[0] if @summaryPages.length > 0

      @loading = false

  mapSummaryPanelsToPages: () ->
    @_.each @summaryPages, (sum_page) =>
      sum_page.summary_panels = @indexedSummaryPanels[parseInt(sum_page.id)]

  saveSummaryPage: (sp) ->
    sp.$update {decision_aid_id: @$stateParams.decisionAidId}, 
      (() => 
        @mapSummaryPanelsToPages()
      ), ((error) => 
        @handleError(error)
      ).$promise

  deleteSummaryPage: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this summary page? All panels within the page will also be deleted.'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @currentlyEditingSummaryPage.$delete {decision_aid_id: @$stateParams.decisionAidId},
        (() => 
          @Sortable.finishItemDeletion(@currentlyEditingSummaryPage, @summaryPages, 'intro_page_order')
          @currentlyActiveEmailIndex = null
          if @summaryPages.length > 0
            @setCurrentlyEditingSummaryPage(@summaryPages[0])
          else
            @currentlyEditingSummaryPage = null 
        ), ((error) => 
          @handleError(error)
        )

  setCurrentlyEditingSummaryPage: (sp) ->
    if @currentlyActiveEmailIndex
      @saveSummaryPage(@currentlyEditingSummaryPage).then () =>
        @currentlyActiveEmailIndex = null
        @currentlyEditingSummaryPage = sp
    else
      @currentlyActiveEmailIndex = null
      @currentlyEditingSummaryPage = sp

  getSummaryPanels: () ->
    @SummaryPanel.query {decision_aid_id: @$stateParams.decisionAidId}, (summaryPanels) =>
      @summaryPanels = summaryPanels
      @loading = false

  onSort: (summaryPanel, partFrom, partTo, indexFrom, indexTo, arr) ->
    if summaryPanel and summaryPanel.summary_panel_order isnt indexTo + 1
      summaryPanel.summary_panel_order = indexTo + 1
      @Sortable.reorderItem(summaryPanel, arr, 'summary_panel_order')

  addEmail: () ->
    if @currentlyActiveEmailIndex
      @saveSummaryPage(@currentlyEditingSummaryPage).then () =>
        @currentlyEditingSummaryPage.summary_email_addresses.push ""
        @currentlyActiveEmailIndex = @currentlyEditingSummaryPage.summary_email_addresses.length-1
    else
      @currentlyEditingSummaryPage.summary_email_addresses.push ""
      @currentlyActiveEmailIndex = @currentlyEditingSummaryPage.summary_email_addresses.length-1

  saveCurrentlyActiveEmail: () ->
    @saveSummaryPage(@currentlyEditingSummaryPage).then () =>
      @currentlyActiveEmailIndex = null

  removeEmail: (index) ->
    @currentlyEditingSummaryPage.summary_email_addresses.splice(index, 1)
    @saveSummaryPage(@currentlyEditingSummaryPage)

  setCurrentlyActiveEmailIndex: (index) ->
    if @currentlyActiveEmailIndex
      @saveSummaryPage(@currentlyEditingSummaryPage).then () =>
        @currentlyActiveEmailIndex = index
    else
      @currentlyActiveEmailIndex = index

  findPrimarySummaryPage: () ->
    @_.find @summaryPages, (sp) =>
      sp.is_primary

  pageMarkedPrimary: () ->
    return if @currentlyEditingSummaryPage.is_primary

    existingPrimaryPage = @findPrimarySummaryPage()

    @currentlyEditingSummaryPage.is_primary = true
    toSave = [@currentlyEditingSummaryPage]

    if existingPrimaryPage
      existingPrimaryPage.is_primary = false
      toSave.push existingPrimaryPage
    
    savePromises = @_.map toSave, (page) =>
      @saveSummaryPage(page)

    @$q.all(savePromises)

  addNewSummaryPage: () ->
    @newSummaryPageButtonDisabled = true
    new_sp = new @SummaryPage
    new_sp.decision_aid_id = @decisionAid.id
    new_sp.include_admin_summary_email = false
    if !@findPrimarySummaryPage()
      new_sp.is_primary = true
    else
      new_sp.is_primary = false

    new_sp.summary_email_addresses = []
    new_sp.$save {decision_aid_id: @$stateParams.decisionAidId}, 
      (() => 
        @summaryPages.push new_sp
        if !@currentlyEditingSummaryPage
          @currentlyEditingSummaryPage = @summaryPages[0]
        @newSummaryPageButtonDisabled = false
      ), ((error) => 
        @handleError(error)
        @newSummaryPageButtonDisabled = false
      ).$promise

  deleteSummaryPanel: (panel) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this summary panel?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      panel.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @$state.go("decisionAidShow.summary", {decisionAidId: @$stateParams.decisionAidId})
        @Sortable.finishItemDeletion(panel, @currentlyEditingSummaryPage.summary_panels, 'intro_page_order')
      ), (
        (error) => @handleError(error)
      )

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditSummaryCtrl', DecisionAidEditSummaryCtrl

