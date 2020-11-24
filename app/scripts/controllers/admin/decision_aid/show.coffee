'use strict'

module = angular.module('dcida20App')

###*
 # @ngdoc controller
 # @name dcida20App.controller:DecisionAidShowCtrl
 # @description
 # # DecisionAidShowCtrl
 # Decision Aid Show controller for DCIDA admin. Displays the decision aid identified
 # by the id parameter in the route
###

class DecisionAidShowCtrl
  @$inject: ['$scope', '$state', '$timeout', '$stateParams', 'DecisionAid', 'DownloadManager', 'moment', 'Confirm', 'DownloadItem', 'API_PUBLIC', '$uibModal']
  constructor: (@$scope, @$state, @$timeout, @$stateParams, @DecisionAid, @DownloadManager, @moment, @Confirm, @DownloadItem, @API_PUBLIC, @$uibModal) ->
    @$scope.ctrl = @
    @loading = true

    @setActiveTab(@$state.current)

    @$scope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) =>
      if toState.name.indexOf("decisionAidShow") > -1
        @$timeout.cancel @exportPromise

    @$scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) =>
      @setActiveTab(toState)

    @$scope.$on 'tabChangeApproved', () =>
      @$state.go "decisionAidShow.#{@tabToChangeTo}"

    @$scope.$on 'decisionAidUpdated', (event, decisionAid) =>
      @decisionAid = decisionAid

    @DecisionAid.get {id: @$stateParams.decisionAidId }, (decisionAid) =>
      @decisionAid = decisionAid
      @$scope.$broadcast 'decisionAidChanged', decisionAid
      @$timeout () =>
        if @$state.current.name == 'decisionAidShow'
          @$state.go 'decisionAidShow.instructions', {}, location: 'replace'
          #@$state.go 'decisionAidShow.optionPropertyMatrix', {}, location: 'replace'
        @loading = false

  setActiveTab: (state) ->
    if state.data? and state.data.stateName?
      @activeTab = state.data.stateName
    else
      @$state.go 'decisionAidShow.instructions', {}, location: 'replace'


  downloadUserData: () ->
    @$uibModal.open(
      templateUrl: "views/admin/decision_aid/download_data_wizard.html"
      controller: "DownloadDataWizard"
      size: 'bigger'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )
    #@DownloadManager.performDownloadRequest(@decisionAid, 'downloadUserData', null, '_userdata_download', @decisionAid)

  changeTab: (tab) ->
    @tabToChangeTo = tab
    @$scope.$broadcast 'tabChangeRequested'

  handleError: (error) ->
    console.log "error handled"

  # openConfirmModal: () ->
  #   @Confirm.downloadReady(
  #       downloadLink: @exportDownloadLink
  #       downloadName: @decisionAid.title + "_export"
  #     )

  # pollForExportedFiles: (di) ->
  #   @DownloadItem.get {id: di.id}, (downloadItem) =>
  #     if downloadItem.processed
  #       @exportDownloadLink = @API_PUBLIC + '/' + downloadItem.file_location
  #       @exportRequested = false
  #       @openConfirmModal()
  #     else
  #       @exportPromise = @$timeout () =>
  #         @pollForExportedFiles(downloadItem)
  #       , 1000
  #   , (error) =>
  #     @exportRequested = false

  clearUserData: () ->
    @Confirm.show(
      message: "Are you sure you want to clear the user data? You cannot undo this action!"
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @decisionAid.clearUserData().then (decisionAid) =>
        @Confirm.alert(
          message: "Success"
          headerClass: 'text-success'
          messageSub: "User data successfully cleared!"
        )
      , (error) =>
        console.log error

  exportDecisionAid: () ->
    @DownloadManager.performDownloadRequest(@decisionAid, 'export', [], '_decision_aid_download', @decisionAid)
    # @exportRequested = true
    # @decisionAid.export().then (di) =>
    #   @pollForExportedFiles(di.download_item)
    # , (error) =>
    #   @exportRequested = false

  deleteDecisionAid: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete your decision aid?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @decisionAid.$delete {decision_aid_id: @$stateParams.decisionAidId}, 
        (() => @$state.go("decisionAidList")), 
        ((error) => @handleError(error))


module.controller 'DecisionAidShowCtrl', DecisionAidShowCtrl

