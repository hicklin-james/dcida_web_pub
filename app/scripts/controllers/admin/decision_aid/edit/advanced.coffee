'use strict'

module = angular.module('dcida20App')


class DecisionAidEditAdvancedCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'Confirm', 'AdminTabHelper', '$timeout', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @Confirm, @AdminTabHelper, @$timeout, @ErrorHandler) ->
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

    @redcapConnectionSuccess = 2
    @loading = false

  testRedcapConnection: () ->
    @redcapConnectionSuccess = 4
    @decisionAidEdit.testRedcapConnection().then (data) =>
      @redcapConnectionSuccess = 1
    , (error) =>
      @redcapConnectionSuccess = 3

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditAdvancedCtrl', DecisionAidEditAdvancedCtrl

