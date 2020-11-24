'use strict'

module = angular.module('dcida20App')


class DecisionAidEditBasicCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'Confirm', 'AdminTabHelper', 'API_PUBLIC', 'ErrorHandler', '_']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @Confirm, @AdminTabHelper, @API_PUBLIC, @ErrorHandler, @_) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @deletedParameters = []

    @decisionAidThemes = [
      {value: "default", key: "Default"},
      {value: "chevron_navigation", key: "Chevron Navigation"},
      {value: "flat", key: "Flat"}
    ]

    @languageCodes = [
      {value: "en", key: "English"},
      {value: "fr", key: "French"}
    ]

    @passwordVisible = false
    @passwordVisibleType = "password"

    @saveSuccess = false

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @loading = false

  showDaPassword: () ->
    @passwordVisible = !@passwordVisible
    @passwordVisibleType = if @passwordVisible then "text" else "password"

  updateSelectedPrimaryParam: (p) ->
    if p.is_primary
      @_.chain(@decisionAidEdit.decision_aid_query_parameters)
        .without(p)
        .each (p) =>
          p.is_primary = false

  addQueryParam: () ->
    @decisionAidEdit.decision_aid_query_parameters.push {input_name: "", output_name: "", is_primary: false}
    @$scope.decisionAidEditForm.$setDirty()

  deleteQueryParam: (p) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this parameter?'
      messageSub: 'Be very careful when deleting this, as any associated data from the patient side will also be destroyed.'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      ind = @_.findIndex(@decisionAidEdit.decision_aid_query_parameters, p)
      @decisionAidEdit.decision_aid_query_parameters.splice(ind, 1)
      if p.id
        p._destroy = 1
        @deletedParameters.push p
      @$scope.decisionAidEditForm.$setDirty()
     ,((error) => 
        console.log("Cancelled query param deletion")
      )

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @decisionAidEdit.decision_aid_query_parameters_attributes = @decisionAidEdit.decision_aid_query_parameters.concat(@deletedParameters)
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditBasicCtrl', DecisionAidEditBasicCtrl

