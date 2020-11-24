'use strict'

module = angular.module('dcida20App')

class MyPropertiesPreviewCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'options', '$uibModalInstance', 'Property', 'DecisionAidUserProperty', '$q', '_', 'themeConfig']
  constructor: (@$scope, @$state, @$location, @Auth, options, @$uibModalInstance, @Property, @DecisionAidUserProperty, @$q, @_, @themeConfig) ->
    @$scope.ctrl = @
    @loading = true
    
    fullDa = options.decisionAid

    @colors = @themeConfig["COLORS"]

    @$q.all([fullDa.preview(), @Property.preview(fullDa.id)]).then (prs) =>
      @decisionAid = prs[0]
      @properties = prs[1]
      sampleProps = @DecisionAidUserProperty.generateSampleUserProperties(@decisionAid.minimum_property_count, @properties, @colors)
      @samplePropHash = @_.indexBy(sampleProps, "property_id")
      @orderedProperties = @orderedProps()
      @loading = false

  remainingProperties: () ->
    if @decisionAid?
      @decisionAid.minimum_property_count - @checkPropertiesLength()
    else
      null

  checkPropertiesLength: () ->
    @_.size(@samplePropHash)

  orderedProps: () ->
    @_.sortBy @samplePropHash, 'order'

  assignPropertyColor: (property) ->
    colorToUse = null
    @_.find @colors, (color) =>
      if !@_.find(@samplePropHash, (property) => property.color is color)
        colorToUse = color
        return true
      else
        return false
    property.color = colorToUse

  adjustPropertyOrders: (deletedProperty) ->
    @_.each @samplePropHash, (property) ->
      if property.order > deletedProperty.order
        property.order-- 

  selectProperty: (property) ->
    if @samplePropHash[property.id]?
      @adjustPropertyOrders(@samplePropHash[property.id])
      delete @samplePropHash[property.id]
    else
      sampleProp = 
        property_id: property.id
        weight: 50
        property_title: property.title
        order: @checkPropertiesLength()

      @assignPropertyColor(sampleProp)
      @samplePropHash[property.id] = sampleProp

    @orderedProperties = @orderedProps()

  close: () ->
    @$uibModalInstance.close()

module.controller 'MyPropertiesPreviewCtrl', MyPropertiesPreviewCtrl
