'use strict'

module = angular.module('dcida20App')

class DecisionAidPasswordCtrl
  @$inject: ['$scope', '$uibModalInstance']
  constructor: (@$scope, @$uibModalInstance) ->
    @$scope.ctrl = @
    @decisionAidPassword = null

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      @cancel()

  close: () ->
    @$uibModalInstance.close(@decisionAidPassword)

  cancel: () ->
    @$uibModalInstance.dismiss 'cancel'

module.controller 'DecisionAidPasswordCtrl', DecisionAidPasswordCtrl

