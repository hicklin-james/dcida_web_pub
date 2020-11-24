'use strict'

module = angular.module('dcida20App')

class DecisionAidSetupDceCtrl
  @$inject: ['$scope', 'Auth', '$timeout', 'Util', 'DecisionAid', 'Confirm', 'options', '$uibModalInstance', 'DownloadManager']
  constructor: (@$scope, @Auth, @$timeout, @Util, @DecisionAid, @Confirm, @options, @$uibModalInstance, @DownloadManager) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAid = @options.decisionAid
    @numQuestions = null
    @numResponses = null
    @numBlocks = null
    @includeOptOut = false

  downloadInProgress: () ->
    @DownloadManager.inProgress()

  submitDceParams: () ->
    if @numQuestions > 0 and @numResponses > 0 and @numBlocks > 0
      #fn = @Util.partial(@decisionAid.setupDce, @numQuestions, @numResponses)
      includeOptOut = (if @decisionAid.dce_type is "conditional" or @decisionAid.dce_type is "opt_out" then true else @includeOptOut)
      @DownloadManager.performDownloadRequest(@decisionAid, 'setupDce', [@numQuestions, @numResponses, @numBlocks, includeOptOut], '_dce_download', @decisionAid)

  close: () ->
    @$uibModalInstance.dismiss('cancel')


module.controller 'DecisionAidSetupDceCtrl', DecisionAidSetupDceCtrl

