'use strict'

module = angular.module('dcida20App')


class DecisionAidEditDceCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'Confirm', 'AdminTabHelper', '$uibModal', 'API_PUBLIC', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @Confirm, @AdminTabHelper, @$uibModal, @API_PUBLIC, @ErrorHandler) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @saveSuccess = false

    @dceTypes = [
      {value: "normal", key: "Normal"},
      {value: "conditional", key: "Conditional"},
      {value: "opt_out", key: "Opt-out"}
    ]

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @loading = false

  setupDce: () ->
    @$uibModal.open(
      templateUrl: "views/admin/decision_aid/setup_dce.html"
      controller: "DecisionAidSetupDceCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAidEdit
    )

  saveAndPreview: () ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview(@decisionAid)
    else
      @preview(@decisionAid)

  preview: (da) ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/dce.html"
      controller: "DcePreviewController"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  uploadDceTemplates: () ->
    @$uibModal.open(
      templateUrl: "views/admin/decision_aid/upload_dce_templates.html"
      controller: "DecisionAidUploadDceTemplatesCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  openQuestionSetEditor: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/dce_question_set_editor.html"
      controller: "DceQuestionSetEditorCtrl"
      size: 'giant'
      resolve:
        options: () =>
          decisionAidId: @decisionAid.id
    )

  getDceColor: (attr_name) ->
    return null if !@decisionAidEdit
    rgbVal = @decisionAidEdit[attr_name]
    fontColor = 'black'
    if rgbVal
      items = rgbVal.replace(/[^\d,]/g, '').split(',')
      console.log items
      if items.length is 3
        fontColor = (if @colourIsLight(parseInt(items[0]), parseInt(items[1]), parseInt(items[2])) then 'black' else 'white')
        console.log fontColor
    {'background-color': rgbVal, 'color': fontColor}

  colourIsLight: (r, g, b) ->
    a = 1 - (0.299 * r + 0.587 * g + 0.114 * b) / 255
    return (a < 0.5)

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditDceCtrl', DecisionAidEditDceCtrl

