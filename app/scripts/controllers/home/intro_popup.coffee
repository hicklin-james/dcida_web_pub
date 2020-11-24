'use strict'

module = angular.module('dcida20App')

class IntroPopupCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm', 'options']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm, options) ->
    @$scope.ctrl = @
    @intro_info = options.intro_info

  closeIntroPopup: () ->
    @$uibModalInstance.close()

module.controller 'IntroPopupCtrl', IntroPopupCtrl

