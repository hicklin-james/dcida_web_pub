'use strict'

module = angular.module('dcida20App')

class DataTargetEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', '$stateParams', 'DataExportField', 'Confirm', 'Sortable', '$q', 'Question', '_', 'Property', 'SummaryPage']
  constructor: (@$scope, @$state, @$uibModal, @$stateParams, @DataExportField, @Confirm, @Sortable, @$q, @Question, @_, @Property, @SummaryPage) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId
    @redcapConnectionSuccess = 2

    @$scope.$watch 'ctrl.dataTarget.exporter.question_response_type', (nv, ov) =>
      if nv isnt ov and (nv is 'radio' or nv is 'yes_no')
        @initRedcapResponseMappingJson()

    @$scope.$watch 'ctrl.dataTarget.exporter_type', (nv, ov) =>
      if nv isnt ov
        if nv is 'Property'
          @loadProperties()
        else if nv is "SummaryPage"
          @loadSummaryPages()
        else if nv is "Other"
          ctrl.dataTarget.exporter_id = -1
          

    @validExporterTypes = [
      {
        key: "Question",
        value: "Question"
      },
      {
        key: "Property",
        value: "Property"   
      },
      {
        key: "SummaryPage",
        value: "SummaryPage"
      },
      {
        key: "Other",
        value: "Other"
      }
    ]

    @dataTargetTypes = [
      key: "REDCap"
      value: "redcap"
    ]

    @redcapConnectionSuccess = 2
    
    promises = []

    if @$stateParams.id
      @isNewDataTarget = false
      @title = "Edit Data Target"
      promises.push @getDataExportField(@$stateParams.id).$promise
    else
      @isNewDataTarget = true
      @title = "New Data Target"
      @dataTarget = new @DataExportField

    @$q.all(promises).then () =>
      @loading = false

  initRedcapResponseMappingJson: () ->
    if @dataTarget.exporter.question_responses
      @dataTarget.redcap_response_mapping = @_.object(@_.map(@dataTarget.exporter.question_responses, (qr) -> 
        [qr.id, (if @dataTarget.redcap_response_mapping[qr.id] then @dataTarget.redcap_response_mapping[qr.id] else "")]
      ))

  testRedcapConnection: () ->
    @redcapConnectionSuccess = 4
    @dataTarget.testRedcapQuestion(@decisionAidId, @dataTarget.redcap_field_name).then (data) =>
      @redcapConnectionSuccess = 1
    , (error) =>
      @redcapConnectionSuccess = 3

  loadSummaryPages: () ->
    @SummaryPage.query {decision_aid_id: @decisionAidId}, (summaryPages) =>
      @summaryPages = summaryPages

  loadProperties: () ->
    @Property.query {decision_aid_id: @$stateParams.decisionAidId}, (properties) =>
      @properties = properties

  getDataExportField: (id) ->
    @DataExportField.get { id: id, decision_aid_id: @$stateParams.decisionAidId }
    , (dataExportField) =>
      @dataTarget = dataExportField

  selectQuestion: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/question_picker.html"
      controller: "QuestionPickerCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAidId: @decisionAidId
          questionType: "demographic,quiz"
          flatten: false
          includeResponses: true
          skipMetadataSelection: true
          questionResponseType: 'radio,text,number,lookup_table,yes_no,json,grid,slider,ranking'
          descriptionText: 'Select a question from the list of questions. 
            The user response will be dynamically added to the text when the user has answered the question.'
    )

    modalInstance.result.then (question) =>
      @dataTarget.exporter_id = question.id
      @dataTarget.exporter = question

  deleteDataExportField: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this data target?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @dataTarget.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.dataTargets", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
  
  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  saveDataExportField: () ->
    if @isNewDataTarget
      @dataTarget.$save {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @$state.go("decisionAidShow.dataTargets", {decisionAidId: @$stateParams.decisionAidId})
      ), ((error) => @handleError(error))
    else
      @dataTarget.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @$state.go("decisionAidShow.dataTargets", {decisionAidId: @$stateParams.decisionAidId})
      ), ((error) => @handleError(error))


module.controller 'DataTargetEditCtrl', DataTargetEditCtrl

