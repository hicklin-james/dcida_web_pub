'use strict'

module = angular.module('dcida20App')

class StaticPageEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', 'Option', '$stateParams', 'DecisionAid', 'StaticPage', 'Confirm', 'Sortable', '$q', 'Question', '_', 'SubDecision']
  constructor: (@$scope, @$state, @$uibModal, @Option, @$stateParams, @DecisionAid, @StaticPage, @Confirm, @Sortable, @$q, @Question, @_, @SubDecision) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId

    promises = []

    if @$stateParams.id
      @isNewStaticPage = false
      @title = "Edit Static Page"
      @getStaticPage(@$stateParams.id)
    else
      @isNewStaticPage = true
      @title = "New Static Page"
      @staticPage = new @StaticPage
      @staticPage.question_ids = []
      @loading = false
    

  getStaticPage: (id) ->
    d = @$q.defer()
    @StaticPage.get { id: id, decision_aid_id: @$stateParams.decisionAidId }, (staticPage) =>
      @staticPage = staticPage
      @loading = false
      d.resolve()
    , (error) =>
      d.reject()
    d.promise

  deleteStaticPage: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this static [age]?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @staticPage.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.staticPages", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
  
  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  saveStaticPage: () ->
    if @isNewStaticPage
      @staticPage.$save {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.staticPages", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
    else
      @staticPage.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.staticPages", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))


module.controller 'StaticPageEditCtrl', StaticPageEditCtrl

