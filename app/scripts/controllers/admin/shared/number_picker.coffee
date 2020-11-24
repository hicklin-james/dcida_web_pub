'use strict'

module = angular.module('dcida20App')

class NumberPickerCtrl
  @$inject: ['$scope', '$uibModalInstance']
  constructor: (@$scope, @$uibModalInstance) ->
    @$scope.ctrl = @
    @number = null

  selectNumber: () ->
    if !isNaN(parseFloat(@number)) && isFinite(@number)
      @$uibModalInstance.close(@number)

  cancelNumberPicker: () ->
    @$uibModalInstance.dismiss('cancel')


module.controller 'NumberPickerCtrl', NumberPickerCtrl

