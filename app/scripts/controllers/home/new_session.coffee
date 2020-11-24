'use strict'

module = angular.module('dcida20App')

class NewSessionCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm) ->
    @$scope.ctrl = @
    @uuid = null
    @pid = null

  closeDcidaIntroPopup: () ->
    ids = 
      uuid: @uuid
      pid: @pid
    @$uibModalInstance.close(ids)




module.controller 'NewSessionCtrl', NewSessionCtrl

