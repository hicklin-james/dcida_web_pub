'use strict'

module = angular.module('dcida20App')

class GraphicsEditCtrl
  @$inject: ['$scope', '$uibModalInstance', "Graphic"]
  constructor: (@$scope, @$uibModalInstance, @Graphic) ->
    @$scope.ctrl = @
    
    #@$scope.watch "ctrl.graphic.graphic_type"
    #console.log @Graphic
    @graphicTypes = @Graphic.graphicTypes
    @graphic = {}

    @graphic.selected_color = "#5cb85c"
    @graphic.unselected_color = '#fa9696'
    @graphic.max = 100
    @graphic.value = 10

  # graphicChanged: () ->
  #   if @graphic.graphic_type is "man_chart"
  #     @graphic.max = 100
  #     @graphic.value = 0
  #   else if @graphic.graphic_type is "circle_chart"
  #     @graphic.max = 100
  #     @graphic.value = 0

  selectValue: (value) ->
    #console.log "hey!"
    @graphic.value = value

  insertGraphic: () ->
    #console.log @graphic
    @$uibModalInstance.close(@graphic)

module.controller 'GraphicsEditCtrl', GraphicsEditCtrl
