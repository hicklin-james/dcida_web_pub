'use strict'

module = angular.module('dcida20App')

class DecisionAidSetupBestWorstCtrl
  @$inject: ['$scope', 'Auth', '$timeout', 'Util', 'DecisionAid', 'Confirm', 'options', '$uibModalInstance', 'DownloadManager']
  constructor: (@$scope, @Auth, @$timeout, @Util, @DecisionAid, @Confirm, @options, @$uibModalInstance, @DownloadManager) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAid = @options.decisionAid
    @numQuestions = null
    @numQuestionAttributes = null
    @numBlocks = null

  downloadInProgress: () ->
    @DownloadManager.inProgress()

  submitBwParams: () ->
    if @numQuestions > 0 and @numQuestionAttributes > 0 and @numBlocks > 0
      #fn = @Util.partial(@decisionAid.setupDce, @numQuestions, @numResponses)
      @DownloadManager.performDownloadRequest(@decisionAid, 'setupBw', [@numQuestions, @numQuestionAttributes, @numBlocks], '_bw_download', @decisionAid)

  close: () ->
    @$uibModalInstance.dismiss('cancel')


module.controller 'DecisionAidSetupBestWorstCtrl', DecisionAidSetupBestWorstCtrl

