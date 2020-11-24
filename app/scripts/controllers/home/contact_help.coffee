'use strict'

module = angular.module('dcida20App')

class ContactHelpCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm', 'options']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm, options) ->
    @$scope.ctrl = @
    @description = options.description

  closePopup: () ->
    @$uibModalInstance.close()

module.controller 'ContactHelpCtrl', ContactHelpCtrl

