'use strict'

module = angular.module('dcida20App')


class DecisionAidEditMyChoiceCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'Confirm', 'AdminTabHelper', '$uibModal', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @Confirm, @AdminTabHelper, @$uibModal, @ErrorHandler) ->
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

  saveAndPreview: () ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview(@decisionAid)
    else
      @preview(@decisionAid)

  preview: (da) ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/my_choice.html"
      controller: "MyChoicePreviewCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  ratingImage: () ->
    if !@decisionAidEdit.ratings_enabled && @decisionAid.decision_aid_type is 'standard'
      "images/no_ratings.png"
    else
      if !@decisionAidEdit.percentages_enabled && !@decisionAidEdit.best_match_enabled
        "images/no_ratings.png"
      else if @decisionAidEdit.percentages_enabled && !@decisionAidEdit.best_match_enabled
        "images/percentages_only.png"
      else if !@decisionAidEdit.percentages_enabled && @decisionAidEdit.best_match_enabled
        "images/best_match_only.png"
      else
        "images/best_match_and_percentages.png"

  checkRatingCheckboxes: () ->
    if !@decisionAidEdit.ratings_enabled
      @decisionAidEdit.percentages_enabled = false
      @decisionAidEdit.best_match_enabled = false

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditMyChoiceCtrl', DecisionAidEditMyChoiceCtrl

