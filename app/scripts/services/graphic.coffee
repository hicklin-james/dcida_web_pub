'use strict'

angular.module('dcida20App')
  .factory 'Graphic', ['_', '$q',  'API_ENDPOINT', 'Util', '$resource', (_, $q, API_ENDPOINT, Util, $resource) ->

    attributes = ['id', 'graphic_data_attributes', 'animated_icon_array_graphic_stages_attributes', 'indicators_above', 'default_stage', 'title', 'selected_index', 'selected_index_type', 'actable_type', 'max_value', 'num_per_row', 'min_value', 'x_label', 'y_label', 'chart_title']
    actions = Util.resourceActions 'graphic', 'graphics', attributes

    Graphic = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/graphics/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    # sub_value attribute defines series
    # label attribute defines y-value
    Graphic.prototype.setupLineChart = () ->
      cats = _.groupBy @graphic_data, "sub_value"
      xvals = _.groupBy @graphic_data, "label"
      if @graphic_data and @graphic_data.length > 0
        @categories = _.keys(cats)
        @x_values = _.keys(xvals)
      else
        @categories = []
        @x_values = []

      fv = {}
      outerCount = 0
      _.each cats, (v, k) =>
        fv[outerCount] = {}
        innerCount = 0
        _.each v, (vv) =>
          fv[outerCount][innerCount] = vv
          innerCount += 1
        outerCount += 1

      @indexedData = fv

    Graphic.prototype.prepareAnimatedIconArrayForUpload = (deletedGraphicStageIds, deletedDataPointIds) ->
      @animated_icon_array_graphic_stages_attributes = angular.copy @animated_icon_array_graphic_stages
      _.each @animated_icon_array_graphic_stages_attributes, (stage, index) ->
        stage.graphic_data_attributes = angular.copy stage.graphic_data
        stage.graphic_stage_order = index + 1
        _.each stage.graphic_data_attributes, (datum, index) ->
          datum.graphic_data_order = index + 1

        deletedDataPointsFromStage = _.filter deletedDataPointIds, (dps) =>
          dps.stage is stage.id

        if deletedDataPointsFromStage.length > 0
          _.each deletedDataPointsFromStage, (dps) =>
            stage.graphic_data_attributes.push {id: dps.deleted_item_id, _destroy: 1}

      _.each deletedGraphicStageIds, (id) =>
        @animated_icon_array_graphic_stages_attributes.push {id: id, _destroy: 1}

    Graphic.prototype.prepareLineChartForUpload = (deletedIds) ->
      @graphic_data_attributes = []
      count = 1
      #console.log "Preparing for upload!"
      #console.log @indexedData
      _.each @indexedData, (xvals, cind) =>
        _.each xvals, (dp, xind) =>
          dp.graphic_data_order = count
          dp.label = @x_values[xind]
          dp.sub_value = @categories[cind]
          dp.value_type = (if dp.value_type is "question_response" then "question_response" else "decimal")
          @graphic_data_attributes.push dp
          count += 1

      _.each deletedIds, (id) =>
        @graphic_data_attributes.push {id: id, _destroy: 1}

      #console.log @graphic_data_attributes
      #console.log deletedIds


    Graphic.prototype.prepareForUpload = (deletedIds) ->
      @graphic_data_attributes = angular.copy @graphic_data
      _.each @graphic_data_attributes, (gd, index) ->
        gd.graphic_data_order = index + 1
        if gd.id and deletedIds.indexOf(gd.id) > -1
          gd._destroy = 1

    return Graphic
  ]
