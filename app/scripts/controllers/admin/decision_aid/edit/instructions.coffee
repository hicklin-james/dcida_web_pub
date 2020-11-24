'use strict'

module = angular.module('dcida20App')


class DecisionAidEditInstructionsCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @$scope.$emit 'tabChangeApproved'

    @$scope.ctrl = @
    @loading = false

module.controller 'DecisionAidEditInstructionsCtrl', DecisionAidEditInstructionsCtrl

