'use strict'

module = angular.module('dcida20App')

class IntroPageEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', '$stateParams', 'IntroPage', 'Confirm', 'Sortable', '$q', '_']
  constructor: (@$scope, @$state, @$uibModal, @$stateParams, @IntroPage, @Confirm, @Sortable, @$q, @_) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId

    if @$stateParams.id
      @isNewIntroPage = false
      @title = "Edit Introduction Page"
      @getIntroPage(@$stateParams.id)
    else
      @isNewIntroPage = true
      @title = "New Introduction Page"
      @introPage = new @IntroPage
      @loading = false

  getIntroPage: (id) ->
    @IntroPage.get { id: id, decision_aid_id: @$stateParams.decisionAidId }, (introPage) =>
      @introPage = introPage
      @loading = false
    , (error) =>
      @errors = error
      @loading = false

  deleteIntroPage: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this introduction page?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @introPage.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.introduction", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
  
  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  saveIntroPage: () ->
    if @isNewIntroPage
      @introPage.$save {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.introduction", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
    else
      @introPage.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.introduction", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))


module.controller 'IntroPageEditCtrl', IntroPageEditCtrl

