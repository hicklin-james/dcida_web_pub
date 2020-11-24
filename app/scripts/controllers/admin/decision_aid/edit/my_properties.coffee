'use strict'

module = angular.module('dcida20App')


class DecisionAidEditMyPropertiesCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'AdminTabHelper', '$uibModal', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @AdminTabHelper, @$uibModal, @ErrorHandler) ->
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

  chartImage: () ->
    if @decisionAidEdit
      if @decisionAidEdit.chart_type is "pie"
        "images/pie_sample.png"
      else
        "images/bar_sample.png"
    else
      null

  setChartType: (t) ->
    if t isnt @decisionAidEdit.chart_type
      @$scope.decisionAidEditForm.$setDirty()
    @decisionAidEdit.chart_type = t

  saveAndPreview: () ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview(@decisionAid)
    else
      @preview(@decisionAid)

  preview: (da) ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/my_properties.html"
      controller: "MyPropertiesPreviewCtrl"
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


module.controller 'DecisionAidEditMyPropertiesCtrl', DecisionAidEditMyPropertiesCtrl

