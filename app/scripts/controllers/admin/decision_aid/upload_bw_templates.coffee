'use strict'

module = angular.module('dcida20App')

class DecisionAidUploadBwTemplatesCtrl
  @$inject: ['$scope', 'Auth', '$timeout', 'UploadManager', 'DecisionAid', 'Confirm', 'options', '$uibModalInstance', 'API_ENDPOINT', 'Upload']
  constructor: (@$scope, @Auth, @$timeout, @UploadManager, @DecisionAid, @Confirm, @options, @$uibModalInstance, @API_ENDPOINT, @Upload) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAid = @options.decisionAid
    @uploadOption = "design"
    @designUpload = null
    @resultsUpload = null

    # @$scope.$on 'uploadManager.uploadInProgressChanged', (e, nv) =>
    #   @uploadInProgress = nv

  uploadInProgress: () ->
    @UploadManager.isUploadInProgress()

  uploadDesign: () ->
    params = 
      url: "#{@API_ENDPOINT}/decision_aids/#{@decisionAid.id}/upload_bw_design"
      file: @designUpload

    @UploadManager.performUploadRequest(params, @decisionAid)

  uploadResults: () ->
    console.info "Not yet implemented"
    # params = 
    #   url: "#{@API_ENDPOINT}/decision_aids/#{@decisionAid.id}/upload_bw_results"
    #   file: @resultsUpload

    # @UploadManager.performUploadRequest(params, @decisionAid)

  close: () ->
    @$uibModalInstance.dismiss('cancel')


module.controller 'DecisionAidUploadBwTemplatesCtrl', DecisionAidUploadBwTemplatesCtrl

