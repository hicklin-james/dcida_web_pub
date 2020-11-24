'use strict'

module = angular.module('dcida20App')

class GraphicListCtrl
  @$inject: ['$scope', '$state', '$uibModalInstance', '$uibModal', 'Graphic', 'options', 'moment', 'Auth', '$q', 'Confirm', '_', '$timeout', 'Sortable']
  constructor: (@$scope, @$state, @$uibModalInstance, @$uibModal, @Graphic, options, @moment, @Auth, @$q, @Confirm, @_, @$timeout, @Sortable) ->
    @$scope.ctrl = @
    
    @loading = true

    # @$scope.$watch "ctrl.currentlyEditing.actable_type", (ov, nv) ->
    #   if nv
    #     @deletedDataPoints = []
    #     @deletedIconArrayStages = []

    @decisionAidId = options.decisionAidId
    @userId = options.userId
    
    @graphicTypes = [{key: "Horizontal Bar Chart", value: "HorizontalBarChartGraphic"},
                    {key: "Icon Array", value: "IconArrayGraphic"},
                    {key: "Line Chart", value: "LineChartGraphic"},
                    {key: "Animated icon array", value: "AnimatedIconArrayGraphic"}]
    
    @horizontalBarChartSelectedIndexTypes = [{key: "Decimal", value: "decimal"}, {key: "Question Response", value: "question_response"}]
    @iconArraySelectedIndexTypes = [{key: "Decimal", value: "decimal"}, {key: "Question Response", value: "question_response"}]

    @graphicDataValueTypes = [{key: "Decimal", value: "decimal"}, {key: "Question Response", value: "question_response"}]
    @graphicDataSubValueTypes = [{key: "Decimal", value: "dec"}, {key: "Question Response", value: "qr"}]

    @lineChartDataValueTypes = [{key: "Decimal", value: "decimal"}, {key: "Question Response", value: "question_response"}]

    @deletedDataPoints = []
    @deletedIconArrayStages = []

    @getGraphics()
    @new()

  getGraphics: () ->
    @Graphic.query {decision_aid_id: @decisionAidId}, (graphics) =>
      @graphics = graphics
      _.each @graphics, (g) =>
        if g.actable_type is "LineChartGraphic"
          g.setupLineChart()
      @loading = false

  resetSelectedIndex: () ->
    @currentlyEditing.selected_index = null

  editGraphic: (graphic) ->
    @currentlyEditing = graphic
    @deletedDataPoints = []
    @deletedIconArrayStages = []

  insert: () ->
    @saveCurrentlyEditing().then (graphic) =>
      @deletedDataPoints = []
      @deletedIconArrayStages = []
      @$uibModalInstance.close(graphic)
    , (error) =>
      @handleError(error)

  insertGraphic: (graphic) ->
    @$uibModalInstance.close(graphic)

  addGraphicStage: () ->
    if !@currentlyEditing.animated_icon_array_graphic_stages
      @currentlyEditing.animated_icon_array_graphic_stages = []
    newStage = {}
    newStage.total_n = 100
    newStage.seperate_values = false
    newStage.graphic_data = []
    @currentlyEditing.animated_icon_array_graphic_stages.push newStage

  save: () ->
    @saveCurrentlyEditing().then (graphic) =>
      @deletedDataPoints = []
      @deletedIconArrayStages = []
      @setSaved()
    , (error) =>
      @handleError(error)

  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  new: () ->
    @currentlyEditing = new @Graphic()
    @currentlyEditing.graphic_data = []
    @currentlyEditing.indicators_above = false
    @currentlyEditing.default_stage = 0
    @currentlyEditing.setupLineChart()

  openQuestionModal: (model, attr) ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/question_picker.html"
      controller: "QuestionPickerCtrl"
      size: 'lg'
      backdrop: 'static'
      resolve: 
        options: () =>
          includeNumeric: true
          questionType: "quiz,demographic"
          decisionAidId: @decisionAidId
          flatten: true
          questionResponseType: 'radio,number,yes_no,lookup_table,json'
          descriptionText: "Select a question from the list of questions."
    )

    modalInstance.result.then (question) =>
      str = null
      if question.additional_meta
        str = "[question id='#{question.id}' #{question.additional_meta}]"
      else
        str = "[question id='#{question.id}']"
      model[attr] = str

  openQuestionSelectorIfNecessary: (dp) ->
    if dp and dp.value_type is "question_response"
      @openQuestionModal(dp, "value")
      # make sure to blur the element after opening the modal
      angular.element(document.activeElement).blur()
      return

  editSelectedIndex: () ->
    @openQuestionModal(@currentlyEditing, "selected_index")

  addGraphicDatumQuestionResponseValue: (graphicDatum) ->
    @openQuestionModal(graphicDatum, "value")

  addGraphicDatumQuestionResponseSubValue: (graphicDatum) ->
    @openQuestionModal(graphicDatum, "sub_value")

  deleteGraphic: (graphic) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this graphic?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      if @currentlyEditing is graphic
        @new()
      graphic.$delete {decision_aid_id: @decisionAidId, actable_type: graphic.actable_type}, () =>
        i = @_.indexOf @graphics, graphic
        if i > -1
          @graphics.splice i, 1

  # sortedData: (datum, partFrom, partTo, indexFrom, indexTo) ->
  #   @Sortable.finishItemDeletion(datum, @currentlyEditing.graphic_data, 'graphic_data_order')

  saveCurrentlyEditing: () ->
    @errors = null
    d = @$q.defer()
    if @currentlyEditing.actable_type is "LineChartGraphic"
      @currentlyEditing.prepareLineChartForUpload(@deletedDataPoints)
    else if @currentlyEditing.actable_type is "AnimatedIconArrayGraphic"
      @currentlyEditing.prepareAnimatedIconArrayForUpload(@deletedIconArrayStages, @deletedDataPoints)
    else
      @currentlyEditing.prepareForUpload(@deletedDataPoints) 

    if @currentlyEditing.id?
      @currentlyEditing.$update {decision_aid_id: @decisionAidId}, (graphic) =>
        graphic.setupLineChart()
        @currentlyEditing = graphic
        d.resolve(graphic)
      , (error) =>
        d.reject(error)
    else
      @currentlyEditing.$save {decision_aid_id: @decisionAidId}, (graphic) =>
        graphic.setupLineChart()
        @currentlyEditing = graphic
        @graphics.push graphic
        d.resolve(graphic)
      , (error) =>
        d.reject(error)
    d.promise

  setSaved: () ->
    @saved = true
    @$timeout () =>
      @saved = false
    , 2000

  cancel: () ->
    @$uibModalInstance.dismiss('cancel')

  addCategoryToLineChart: () ->
    @currentlyEditing.categories.push ""

  addXValueToLineChart: () ->
    @currentlyEditing.x_values.push ""

  deleteCategoryFromLineChart: (index) ->
    deletedCat = @_.find @currentlyEditing.indexedData, (xvals, cind) => parseInt(cind) is index
    #console.log deletedCat
    @_.each deletedCat, (dp, xind) =>
      if dp.id?
        @deletedDataPoints.push dp.id
    delete @currentlyEditing.indexedData[index]
    counter = 0
    @_.each @currentlyEditing.indexedData, (val, key) =>
      if counter != parseInt(key)
        Object.defineProperty(@currentlyEditing.indexedData, counter, Object.getOwnPropertyDescriptor(@currentlyEditing.indexedData, key))
        delete @currentlyEditing.indexedData[key]
      counter += 1
    @currentlyEditing.categories.splice(index, 1)

  deleteXValFromLineChart: (index) ->
    @_.each @currentlyEditing.indexedData, (xvals, cat) =>
      deletedXVal = @_.find xvals, (dp, xind) => parseInt(xind) is index
      if deletedXVal.id?
        @deletedDataPoints.push deletedXVal.id
      #console.log deletedXVal
      delete @currentlyEditing.indexedData[cat][index]
      counter = 0
      @_.each @currentlyEditing.indexedData[cat], (val, key) =>
        if counter != parseInt(key)
          Object.defineProperty(@currentlyEditing.indexedData[cat], counter, Object.getOwnPropertyDescriptor(@currentlyEditing.indexedData[cat], key))
          delete @currentlyEditing.indexedData[cat][key]
        counter += 1
    @currentlyEditing.x_values.splice(index, 1)

  setValueType: (catIndex, xValIndex, type) ->
    if !@currentlyEditing.indexedData[catIndex]
      @currentlyEditing.indexedData[catIndex] = {}
      @currentlyEditing.indexedData[catIndex][xValIndex] = {}
    else if @currentlyEditing.indexedData[catIndex] and !@currentlyEditing.indexedData[catIndex][xValIndex]
      @currentlyEditing.indexedData[catIndex][xValIndex] = {}

     @currentlyEditing.indexedData[catIndex][xValIndex].value_type = type

  addGraphicDataPoint: () ->
    newDataPoint = {}
    if !@currentlyEditing.graphic_data
      @currentlyEditing.graphic_data = []
    @currentlyEditing.graphic_data.push newDataPoint

  deleteStageFromGraphic: (stageIndex) ->
    if @currentlyEditing.animated_icon_array_graphic_stages[stageIndex].id?
      @deletedIconArrayStages.push @currentlyEditing.animated_icon_array_graphic_stages[stageIndex].id

    @currentlyEditing.animated_icon_array_graphic_stages.splice(stageIndex, 1)

  deleteDataPointFromStage: (dpIndex, stage) ->
    if stage.graphic_data[dpIndex].id?
      @deletedDataPoints.push({stage: stage.id, deleted_item_id: stage.graphic_data[dpIndex].id})

    stage.graphic_data.splice(dpIndex, 1);

  addDataToStage: (stage) ->
    newDataPoint = {}
    stage.graphic_data.push newDataPoint

module.controller 'GraphicListCtrl', GraphicListCtrl

