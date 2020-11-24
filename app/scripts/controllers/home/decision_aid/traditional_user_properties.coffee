'use strict'

module = angular.module('dcida20App')

class TraditionalUserPropertyCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', '_', 'Confirm', 'options', 'DecisionAidUserProperty', '$state', 'StateChangeRequested']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @_, @Confirm, options, @DecisionAidUserProperty, @$state, @StateChangeRequested) ->
    @$scope.ctrl = @

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      @closeWindow()

    @decisionAid = options.decisionAid
    @properties = @_.sortBy options.properties, 'property_order'
    @decisionAidUser = options.decisionAidUser
    @options = options.options
    @indexedOptions = @_.indexBy options.options, "id"
    @currentProperty = options.currentProperty
    @optionProperties = options.optionProperties
    @completed = options.completed
    @dontSaveOnClose = options.dontSaveOnClose
    existingProps = options.userProps
    #console.log existingProps
    missingProps = @DecisionAidUserProperty.createMissingProperties(existingProps, @properties, @decisionAidUser)
    #console.log missingProps
    @allProps = existingProps.concat missingProps
    #console.log @allProps
    @userPropsHash = @_.indexBy @allProps, 'property_id'

    @traditionalValueSelections = [
      value: 1
      label: "Not Important"
     ,
      value: 2
      label: "Somewhat Important"
     ,
      value: 3
      label: "Moderately Important"
     ,
      value: 4
      label: "Important"
     ,
      value: 5
      label: "Very Important"
    ]

    #console.log @userPropsHash

    #@optionPropertiesHash = @_.indexBy(options.optionProperties, 'option_id')
    #console.log @optionPropertiesHash

  option_color_class: (option_id) ->
    if !option_id?
      return "text-lightgrey"
    if option_id == 0
      return "option-0-color"
    else
      return "option-#{@indexedOptions[option_id].option_order}-color"

  option_button_color_class: (option_id) ->
    if @userPropsHash[@currentProperty.id] and option_id is @userPropsHash[@currentProperty.id].traditional_option_id
      return "option-#{@indexedOptions[option_id].option_order}-button"
    else
      return null

  setCurrentProperty: (prop) ->
    if @userPropsHash[prop.id].traditional_value
      @currentProperty = prop

  clearCurrentProperty: () ->
    @currentProperty = null

  setUserPropTraditionalValue: (val) ->
    @userPropsHash[@currentProperty.id].traditional_value = val 

  setUserPropTraditionalOptionId: (option_id) ->
    @userPropsHash[@currentProperty.id].traditional_option_id = option_id
    @$scope.$apply

  prev: () ->
    if @currentProperty and @currentProperty.property_order > 1
      @currentProperty = @properties[@currentProperty.property_order - 2]
    else
      @currentProperty = null

  close: () ->
    if @dontSaveOnClose
      @closeWindow()
    else
      @saveAndClose()

  saveAndClose: () ->
    @DecisionAidUserProperty.updateSelections(@_.toArray(@userPropsHash), @decisionAidUser.id).then (decisionAidUserProperties) =>
      @completedUserProps = decisionAidUserProperties
      if @completedUserProps.length isnt @properties.length
        @$state.go 'decisionAidAbout', {slug: @decisionAid.slug, back: true}
      @closeWindow()
    , (error) =>
      console.error "An error occured"
      @backingOut = false

  backOut: () ->
    if @completed
      if @dontSaveOnClose
        @closeWindow()
      else
        @saveAndClose()
      return
    # clear selections on current page
    if @currentProperty && @userPropsHash[@currentProperty.id] and !@userPropsHash[@currentProperty.id].id
      @userPropsHash[@currentProperty.id].traditional_option_id = null
      @userPropsHash[@currentProperty.id].traditional_value = null 
    # save previous selections  
    if !@backingOut
      @backingOut = true
      @userPropsHash = @_.filter @_.toArray(@userPropsHash), (up) => up.traditional_value and (up.traditional_option_id || up.traditional_option_id is 0)
      @saveAndClose()

  next: () ->
    if !@currentProperty
      @currentProperty = @properties[0]
    else if @currentProperty.property_order < @properties.length
      @currentProperty = @properties[@currentProperty.property_order]
    else
      @saveAndClose()

  closeWindow: () ->
    @$uibModalInstance.close(@completedUserProps)
    @backingOut = false

module.controller 'TraditionalUserPropertyCtrl', TraditionalUserPropertyCtrl

