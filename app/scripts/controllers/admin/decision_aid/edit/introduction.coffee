'use strict'

module = angular.module('dcida20App')


class DecisionAidEditIntroductionCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'AdminTabHelper', '$uibModal', 'IntroPage', 'Sortable', 'Confirm', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @AdminTabHelper, @$uibModal, @IntroPage, @Sortable, @Confirm, @ErrorHandler) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @extraInfoVisible = false

    @getIntroPages()

  getIntroPages: () ->
    @IntroPage.query {decision_aid_id: @$stateParams.decisionAidId}, (introPages) =>
      @introPages = introPages
      @loading = false

  onSort: (introPage, partFrom, partTo, indexFrom, indexTo) ->
    if introPage and introPage.intro_page_order isnt indexTo + 1
      introPage.intro_page_order = indexTo + 1
      @Sortable.reorderItem(introPage, @introPages, 'intro_page_order')

  deleteIntroPage: (page) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this introduction page?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      page.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @$state.go("decisionAidShow.introduction", {decisionAidId: @$stateParams.decisionAidId})
        @Sortable.finishItemDeletion(page, @introPages, 'intro_page_order')
      ), (
        (error) => @handleError(error)
      )

  handleError: () ->
    console.log "Handled error"

  saveAndPreview: () ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview(@decisionAid)
    else
      @preview(@decisionAid)

  preview: (da) ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/introduction.html"
      controller: "IntroductionPreviewCtrl"
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

module.controller 'DecisionAidEditIntroductionCtrl', DecisionAidEditIntroductionCtrl

