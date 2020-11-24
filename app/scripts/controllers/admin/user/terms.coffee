'use strict'

module = angular.module('dcida20App')

class TermsOfServiceCtrl
  @$inject: ['$scope', '$uibModalInstance']
  constructor: (@$scope, @$uibModalInstance) ->
    @$scope.ctrl = @
    @number = null

  close: () ->
    @$uibModalInstance.close()


module.controller 'TermsOfServiceCtrl', TermsOfServiceCtrl

