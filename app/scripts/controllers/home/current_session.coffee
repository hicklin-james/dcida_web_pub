'use strict'

module = angular.module('dcida20App')

class CurrentSessionCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm', 'options']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm, options) ->
    @$scope.ctrl = @
    
    @decisionAidUser = options.decisionAidUser

  close: () ->
    @$uibModalInstance.close()


module.controller 'CurrentSessionCtrl', CurrentSessionCtrl

