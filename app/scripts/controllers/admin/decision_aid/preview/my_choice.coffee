'use strict'

module = angular.module('dcida20App')

class MyChoicePreviewCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'options', 'DecisionAidUserOptionProperty', '$uibModalInstance', 'Option', 'Property', 'OptionProperty', '$q', '_']
  constructor: (@$scope, @$state, @$location, @Auth, options, @DecisionAidUserOptionProperty, @$uibModalInstance, @Option, @Property, @OptionProperty, @$q, @_) ->
    @$scope.ctrl = @
    
    fullDa = options.decisionAid

    @$q.all([fullDa.preview(), @Option.preview(fullDa.id), @Property.preview(fullDa.id), @OptionProperty.preview(fullDa.id)]).then (prs) =>
      @decisionAid = prs[0]
      @options = prs[1]
      @properties = prs[2]
      @optionProperties = prs[3]
      @optionPropertyHash = {}
      @decisionAidUser = 
        id: 1
        selectedOptionId: null
      @_.each @optionProperties, (op) =>
        if !@optionPropertyHash[op.property_id]?
          @optionPropertyHash[op.property_id] = {}
        @optionPropertyHash[op.property_id][op.option_id] = op
      @dauopsHash = {}
      userProps = @DecisionAidUserOptionProperty.createMissingOptionProperties([], @optionProperties, @decisionAidUser)
      @_.each userProps, (op) =>
        if !@dauopsHash[op.property_id]?
          @dauopsHash[op.property_id] = {}
        @dauopsHash[op.property_id][op.option_id] = op
      #console.log @decisionAidUser

  selectOption: (option) ->
    @decisionAidUser.selected_option_id = option.id
  
  close: () ->
    @$uibModalInstance.close()

module.controller 'MyChoicePreviewCtrl', MyChoicePreviewCtrl
