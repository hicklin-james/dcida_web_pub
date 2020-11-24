'use strict'

module = angular.module('dcida20App')

class DecisionAidEditDataTargetsCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'AdminTabHelper', '$uibModal', 'Confirm', 'ErrorHandler', '_', 'DataExportField', 'Sortable']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @AdminTabHelper, @$uibModal, @Confirm, @ErrorHandler, @_, @DataExportField, @Sortable) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.ctrl = @

    @loading = true

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @getDataTargets()

  getDataTargets: () ->
    @DataExportField.query {decision_aid_id: @$stateParams.decisionAidId}, (dataTargets) =>
      @dataTargets = dataTargets
      @loading = false

  onSort: (dataTarget, partFrom, partTo, indexFrom, indexTo) ->
    if dataTarget and dataTarget.data_export_field_order isnt indexTo + 1
      dataTarget.data_export_field_order = indexTo + 1
      @Sortable.reorderItem(dataTarget, @dataTargets, 'data_export_field_order')

  deleteDataTarget: (dataTarget) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this data target?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      dataTarget.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @Sortable.finishItemDeletion(dataTarget, @dataTargets, 'data_export_field_order')
      ), (
        (error) => @handleError(error)
      )

  onSort: (dataTarget, partFrom, partTo, indexFrom, indexTo) ->
    if dataTarget and dataTarget.data_export_field_order isnt indexTo + 1
      dataTarget.data_export_field_order = indexTo + 1
      @Sortable.reorderItem(dataTarget, @dataTargets, 'data_export_field_order')

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))

module.controller 'DecisionAidEditDataTargetsCtrl', DecisionAidEditDataTargetsCtrl

