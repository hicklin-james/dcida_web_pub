'use strict'

module = angular.module('dcida20App')

class ResultsMoreInfoCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm', 'options']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm, options) ->
    @$scope.ctrl = @
    @options = options.options
    @property = options.property
    @optionPropertiesHash = @_.indexBy(options.optionProperties, 'option_id')
    #console.log @optionPropertiesHash

  closeMoreInfoPopup: () ->
    @$uibModalInstance.close()




module.controller 'ResultsMoreInfoCtrl', ResultsMoreInfoCtrl

