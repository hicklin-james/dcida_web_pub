'use strict'

module = angular.module('dcida20App')

class DecisionAidTraditionalPropertiesCtrl
  @$inject: ['$scope', '$document', '$timeout', '$state', '$ngSilentLocation', '$stateParams', 'DecisionAidHome', 'DecisionAidUserProperty', 'moment', 'Auth', '_', 'Confirm', 'NavBroadcastService', 'themeConfig', 'StateChangeRequested']
  constructor: (@$scope, @$document, @$timeout, @$state, @$ngSilentLocation, @$stateParams, @DecisionAidHome, @DecisionAidUserProperty, @moment, @Auth, @_, @Confirm, @NavBroadcastService, @themeConfig, @StateChangeRequested) ->
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @decisionAid = null
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)

    @$scope.$watch "ctrl.checkPropertiesLength()", (new_val, old_val) =>
      if @hasScrolled? and @hasScrolled is false
        if new_val >= @decisionAid.minimum_property_count
          @Confirm.alert(
            message: "Done!"
            messageSub: "Please scroll down. Move the sliders to show how important each factor is to you."
            headerClass: "text-success"
            buttonType: "default"
          )
          @hasScrolled = true
      
    @colors = @themeConfig["COLORS"]

    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null

    @DecisionAidHome.traditionalProperties(@decisionAidSlug).then ((data) =>
      #console.log "YOLO1"
      @decisionAid = data.decision_aid
      @decisionAidUser = data.meta.decision_aid_user
      @properties = data.decision_aid.properties
      @allSortedProperties = @_.sortBy(@properties, "property_order")
      @options = data.decision_aid.options
      #@option_properties = @_.indexdata.decision_aid.option_properties
      @option_properties = {}
      @_.each data.decision_aid.option_properties, (op) =>
        @option_properties[op.property_id] = {} if !@option_properties[op.property_id]?
        @option_properties[op.property_id][op.option_id] = op


      @DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id}, (decisionAidUserProperties) =>
        @propertiesHash = @_.indexBy(decisionAidUserProperties, 'property_id')
        #console.log @propertiesHash

        @filteredProperties = @_.filter @properties, (p) => @propertiesHash[p.id]?
        #console.log @filteredProperties

        @indexedProperties = @_.indexBy @filteredProperties, "id"
        if @$stateParams.property_id && !@indexedProperties[parseInt(@$stateParams.property_id)]
          @$stateParams.property_id = null

        if !@$stateParams.property_id && !@$stateParams.back
          @$stateParams.back = null
          @$state.params.back = null
          @$ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/traditional_properties")
          @currPage = "selectingProps"
        else 
          propid = if @$stateParams.back then @filteredProperties[@filteredProperties.length-1].id else @$stateParams.property_id
          @$stateParams.property_id = propid
          @currPage = "property"
          @currProperty = @indexedProperties[parseInt(propid)]
          #console.log @currProperty
          @propIndex = @_.findIndex @filteredProperties, (p) => p.id is @currProperty.id
          #console.log @propIndex

        @hasScrolled = if @checkPropertiesLength() >= @decisionAid.minimum_property_count then true else false
        @orderedProperties = @orderedUserProperties()
        @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)

        #@$scope.$emit 'dcida.percentageCompletedUpdate', {checkNextPage: true}
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    ),
    ((error) =>
      @noDecisionAidFound = true
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    )

  remainingProperties: () ->
    if @decisionAid?
      @decisionAid.minimum_property_count - @checkPropertiesLength()
    else
      null

  checkPropertiesLength: () ->
    @_.size(@propertiesHash)

  orderedUserProperties: () ->
    @_.sortBy @propertiesHash, 'order'

  assignPropertyColor: (property) ->
    colorToUse = null
    @_.find @colors, (color) =>
      if !@_.find(@propertiesHash, (property) => property.color is color)
        colorToUse = color
        return true
      else
        return false
    property.color = colorToUse

  setUserPropTraditionalOptionId: (option_id) ->
    @propertiesHash[@currProperty.id].traditional_option_id = option_id

  adjustPropertyOrders: (deletedProperty) ->
    @_.each @propertiesHash, (property) ->
      if property.order > deletedProperty.order
        property.order-- 

  selectProperty: (property) ->
    if @propertiesHash[property.id]?
      @adjustPropertyOrders(@propertiesHash[property.id])
      delete @propertiesHash[property.id]
    else
      newProperty = new @DecisionAidUserProperty
      newProperty.initialize(property, @decisionAidUser, @_.toArray(@propertiesHash).length)
      @assignPropertyColor(newProperty)
      @propertiesHash[property.id] = newProperty

    @orderedProperties = @orderedUserProperties()

  submitNext: () ->
    if @$stateParams.property_id
      #propIndex = @_.findIndex @filteredProperties, (p) => p.id is @currProperty.id
      #console.log propIndex
      #console.log @propertiesHash[@currProperty.id]
      if @propertiesHash[@currProperty.id].traditional_option_id
        @DecisionAidUserProperty.updateSelections(@_.toArray(@propertiesHash), @decisionAidUser.id).then (decisionAidUserProperties) =>
          if @propIndex is @filteredProperties.length - 1
            if @decisionAid.quiz_questions_count > 0
              @$state.go 'decisionAidQuiz', {slug: @decisionAidSlug}
            else
              @$state.go 'decisionAidSummary', {slug: @decisionAidSlug}
          else
            @$state.go 'decisionAidTraditionalProperties', {slug: @decisionAidSlug, property_id: @filteredProperties[@propIndex+1].id}
      else
        @Confirm.info
          message: 'Oops'
          messageSub: "Please give a response to continue"
    else
      if @checkSelectedPropertyLength()
        firstProperty = @_.find(@allSortedProperties, (p) => @propertiesHash[p.id])
        @DecisionAidUserProperty.updateSelections(@_.toArray(@propertiesHash), @decisionAidUser.id).then (decisionAidUserProperties) =>
          @$state.go 'decisionAidTraditionalProperties', {slug: @decisionAidSlug, property_id: firstProperty.id}     
      else
        @Confirm.info
          message: 'Oops'
          messageSub: "Please select at least #{@decisionAid.minimum_property_count} factors to continue."
    # @DecisionAidUserProperty.updateSelections(@_.toArray(@propertiesHash), @decisionAidUser.id).then (decisionAidUserProperties) =>
    #   @$state.go 'decisionAidResults', {slug: @decisionAidSlug}
    # ,(error) =>
    #   console.log error
      
  checkSelectedPropertyLength: () ->
    if @_.size(@propertiesHash) <= @decisionAid.maximum_property_count and @_.size(@propertiesHash) >= @decisionAid.minimum_property_count
      true
    else
      false

  prevLink: () ->
    #console.log @currPage
    if !@$stateParams.property_id
      if @decisionAid.demographic_questions_count == 0
        @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: true})
      else
        @$state.go "decisionAidAbout", {slug: @decisionAidSlug, back: true}
    else
      #propIndex = @_.findIndex @filteredProperties, (p) => p.id is @currProperty.id
      if @propIndex is 0
        @$state.go 'decisionAidTraditionalProperties', {slug: @decisionAidSlug, back: null, property_id: null}
      else
        @$state.go 'decisionAidTraditionalProperties', {slug: @decisionAidSlug, back: null, property_id: @filteredProperties[@propIndex-1].id}


module.controller 'DecisionAidTraditionalPropertiesCtrl', DecisionAidTraditionalPropertiesCtrl

