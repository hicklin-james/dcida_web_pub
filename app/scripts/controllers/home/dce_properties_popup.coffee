'use strict'

module = angular.module('dcida20App')

class DcePropertiesPopupCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm', 'options']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm, options) ->
    @$scope.ctrl = @
    @property_title = options.property_title
    @property_long_about = options.property_long_about
    
  closePopup: () ->
    @$uibModalInstance.close()

module.controller 'DcePropertiesPopupCtrl', DcePropertiesPopupCtrl

