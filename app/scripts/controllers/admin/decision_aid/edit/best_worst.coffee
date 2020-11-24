'use strict'

module = angular.module('dcida20App')


class DecisionAidEditBestWorstCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'Confirm', 'AdminTabHelper', '$uibModal', 'API_PUBLIC', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @Confirm, @AdminTabHelper, @$uibModal, @API_PUBLIC, @ErrorHandler) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @saveSuccess = false

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @loading = false

  setupBw: () ->
    @$uibModal.open(
      templateUrl: "views/admin/decision_aid/setup_bw.html"
      controller: "DecisionAidSetupBestWorstCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  uploadBwTemplates: () ->
    @$uibModal.open(
      templateUrl: "views/admin/decision_aid/upload_bw_templates.html"
      controller: "DecisionAidUploadBwTemplatesCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  openLatentClassEditor: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/latent_class_editor.html"
      controller: "LatentClassEditorCtrl"
      size: 'giant'
      resolve:
        options: () =>
          decisionAidId: @decisionAid.id
    )

  saveAndPreview: () ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview()
    else
      @preview()
  
  preview: () ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/best_worst.html"
      controller: "BestWorstPreviewCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditBestWorstCtrl', DecisionAidEditBestWorstCtrl

