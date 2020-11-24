'use strict'

module = angular.module('dcida20App')

class ResponsePopupsCtrl
  @$inject: ['$scope', '$uibModalInstance', '_', 'Confirm', 'options']
  constructor: (@$scope, @$uibModalInstance, @_, @Confirm, options) ->
    @$scope.ctrl = @
    @responsePopups = options.response_popups
    @currentResponseIndex = 0

  nextResponse: () ->
    if @currentResponseIndex + 1 <= @responsePopups.length-1
      @currentResponseIndex += 1

  prevResponse: () ->
    if @currentResponseIndex - 1 >= 0
      @currentResponseIndex -= 1

  closeIntroPopup: () ->
    @$uibModalInstance.close()

module.controller 'ResponsePopupsCtrl', ResponsePopupsCtrl

