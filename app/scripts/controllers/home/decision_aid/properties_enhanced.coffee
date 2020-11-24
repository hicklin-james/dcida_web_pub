'use strict'

module = angular.module('dcida20App')

class DecisionAidPropertiesEnhancedCtrl
  @$inject: ['$scope', '$document', 'Confirm', '$timeout', '$state', '$stateParams', 'DecisionAidHome', 'DecisionAidUserProperty', 'DecisionAidUserOptionProperty', 'moment', 'Auth', '_', 'NavBroadcastService', 'themeConfig', 'StateChangeRequested']
  constructor: (@$scope, @$document, @Confirm, @$timeout, @$state, @$stateParams, @DecisionAidHome, @DecisionAidUserProperty, @DecisionAidUserOptionProperty, @moment, @Auth, @_, @NavBroadcastService, @themeConfig, @StateChangeRequested) ->
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @invalidDecisionAid()

    @$scope.$
      
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

    @colors = @themeConfig["COLORS"]

    @decisionAidSlug = @$stateParams.slug

    @decisionAid = null
    @propertiesHash = {}

    @DecisionAidHome.propertiesEnhanced(@decisionAidSlug).then ((data) =>
      @decisionAid = data.decision_aid
      @decisionAidUser = data.meta.decision_aid_user
      @properties = data.decision_aid.properties
      @indexedProperties = @_.indexBy @properties, "id"
      #@_.each @properties, (p) =>
      #  @selectProperty(p)
      @allOptionProperties = data.decision_aid.option_properties
      @optionProperties = @_.groupBy data.decision_aid.option_properties, 'property_id'
      @groupedOptionProperties = {}
      @_.each @optionProperties, (v, k) =>
        @groupedOptionProperties[k] = []
        @_.each v, (op) =>
          sameLevel =  @_.find @groupedOptionProperties[k], (p) => p.button_label is op.button_label
          if sameLevel
            if !sameLevel.referencedOps
              sameLevel.referencedOps = []
            sameLevel.referencedOps.push op.id
          else
            @groupedOptionProperties[k].push op

        if @groupedOptionProperties[k].length is 1 or (@indexedProperties[k] && !@indexedProperties[k].are_option_properties_weighable)
          delete @groupedOptionProperties[k]

      #@maxSliderValue = (if @decisionAid.advanced_properties then 100 else 10)
      @step = (if @decisionAid.advanced_properties then 1 else 10)

      @DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id, "property_ids[]": @_.pluck(@properties, "id")}, (decisionAidUserProperties) =>
        @DecisionAidUserOptionProperty.query {decision_aid_user_id: @decisionAidUser.id}, (dauops) =>
          missingProps = DecisionAidUserOptionProperty.createMissingOptionProperties(dauops, @allOptionProperties, @decisionAidUser)
          combinedProps = dauops.concat missingProps

          @dauopsHash = {}
          _.each combinedProps, (op) =>
            
            @dauopsHash[op.property_id] = {} if !@dauopsHash[op.property_id]?

            @dauopsHash[op.property_id][op.option_id] = op

          @propertiesHash = @_.indexBy(decisionAidUserProperties, 'property_id')
          @hasScrolled = if @checkPropertiesLength() >= @decisionAid.minimum_property_count then true else false
          @orderedProperties = @orderedUserProperties()
          
          @_.each @properties, (p) =>
            if @propertiesHash[p.id]
              p.weight = @propertiesHash[p.id].weight


          @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)
          @$scope.$emit 'dcida.percentageCompletedUpdate', {checkNextPage: true}
          @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    ),
    ((error) =>
      @noDecisionAidFound = true
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
    )

  valChanged: (property) ->
    if property.weight > 0
      if !@propertiesHash[property.id]
        @selectProperty(property)
      @propertiesHash[property.id].weight = property.weight
    else
      delete @propertiesHash[property.id]

    @orderedProperties = @orderedUserProperties()

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

  setOptionPropertyValue: (uop, v, op) ->
    uop.value = v
    if op.referencedOps
      @_.each op.referencedOps, (opid) =>
        found = @_.find @dauopsHash[op.property_id], (otherUop) => otherUop.option_property_id is opid
        if found
          found.value = v

  invalidDecisionAid: () ->
    @decisionAid = null
    @NavBroadcastService.emitLoadingToRoot(false, @$scope)

  submitNext: () ->
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @DecisionAidUserProperty.updateSelections(@_.toArray(@propertiesHash), @decisionAidUser.id).then (decisionAidUserProperties) =>
      finalDauops = []
      @_.each @dauopsHash, (dauops) => _.each dauops, (dauop) => finalDauops.push dauop

      @DecisionAidUserOptionProperty.updateUserOptionProperties(finalDauops, @decisionAidUser.id).then () =>
        if @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
          if @decisionAid.quiz_questions_count > 0
            @$state.go "decisionAidQuiz", {slug: @decisionAidSlug}
          else
            @$state.go "decisionAidSummary", {slug: @decisionAidSlug}
        else
          @$state.go 'decisionAidResults', {slug: @decisionAidSlug}
      , (error) =>
        console.log error
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)
        @loading = false

    ,(error) =>
      console.log error
      @NavBroadcastService.emitLoadingToRoot(false, @$scope)
      @loading = false
      
  prevLink: () ->
    if @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
      @$state.go "decisionAidResults", {slug: @decisionAidSlug, sub_decision_order: @decisionAidUser.decision_aid_user_sub_decision_choices_count}
    else if @decisionAid.demographic_questions_count == 0
      @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: true})
    else
      @$state.go "decisionAidAbout", {slug: @decisionAidSlug, back: true}



module.controller 'DecisionAidPropertiesEnhancedCtrl', DecisionAidPropertiesEnhancedCtrl
