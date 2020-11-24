'use strict'

module = angular.module('dcida20App')

class OptionPropertyEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', '$stateParams', '_', 'Option', 'DecisionAid', 'OptionProperty', 'Confirm', '$q']
  constructor: (@$scope, @$state, @$uibModal, @$stateParams, @_, @Option, @DecisionAid, @OptionProperty, @Confirm, @$q) ->
    @$scope.ctrl = @
    @decisionAidId = @$stateParams.decisionAidId

    @rankingTypes = [
      {
        key: 'Integer',
        value: 'integer'
      }
     ,{
        key: 'Question Response Value',
        value: 'question_response_value'
      }
    ]

    @loading = true

    p1 = @getOption()
    p2 = @getDecisionAid().$promise

    @$q.all([p1,p2]).then () =>
      @loading = false
    , (error) =>
      @loading = false

  # setupOptionProperty: () ->
  #   if @option.has_sub_options
  #     @multipleOptionProperties = true
  #     @numberOfOptionProperties = @option.sub_options.length
  #     @getOptionProperties()
  #   else
  #     @multipleOptionProperties = false
  #     @currentlyEditing = @optionProperty

  changedRankingType: () ->
    @currentlyEditing.ranking = null

  selectQuestion: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/question_picker.html"
      controller: "QuestionPickerCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAidId: @$stateParams.decisionAidId
          questionType: 'demographic'
          questionResponseType: 'radio,yes_no,lookup_table'
          descriptionText: 'Select a question from the list of questions. 
            The numeric response value will be used as the option property ranking.'
    )

    modalInstance.result.then (question) =>
      @currentlyEditing.ranking = "[question id=\"#{question.id}\"]"

  selectOptionProperty: (op) ->
    @currentlyEditing = op

  getOption: () ->
    d = @$q.defer()
    @Option.get { id: @$stateParams.optionId, decision_aid_id: @$stateParams.decisionAidId }
    , (option) =>
      @option = option
      if @option.has_sub_options
        @getOptionProperties().then () =>
          d.resolve()
        , (error) =>
          @handleError(error)
          d.reject()
      else
        @getOptionProperty().then () =>
          d.resolve()
        , (error) =>
          @handleError(error)
          d.reject()
    , (error) =>
      @handleError(error)
      d.reject()
    d.promise

  getOptionProperties: () ->
    d = @$q.defer()
    @title = "Edit Option Property"
    @isNewOptionProperty = true
    @OptionProperty.query {decision_aid_id: @$stateParams.decisionAidId, super_option_id: @option.id, property_id: @$stateParams.propertyId}, 
    (option_properties) =>
      optionProperties = option_properties
      @optionProperties = @OptionProperty.addNewOptionProperties(optionProperties, @option, @$stateParams.propertyId)
      @currentlyEditing = @optionProperties[0]
      d.resolve()
    , (error) =>
      d.reject(error)
    d.promise

  getOptionProperty: () ->
    d = @$q.defer()
    if @$stateParams.id
      @isNewOptionProperty = false
      @title = "Edit Option Property"
      @OptionProperty.get { id: @$stateParams.id, decision_aid_id: @$stateParams.decisionAidId }
      , (optionProperty) =>
        @optionProperty = optionProperty
        @currentlyEditing = @optionProperty
        d.resolve()
      , (error) =>
        d.reject(error)
    else
      @isNewOptionProperty = true
      @title = "New Option Property"
      @optionProperty = new @OptionProperty
      @optionProperty.option_id = @$stateParams.optionId
      @optionProperty.property_id = @$stateParams.propertyId
      @currentlyEditing = @optionProperty
      d.resolve()
    d.promise

  getDecisionAid: () ->
    @DecisionAid.get { id: @$stateParams.decisionAidId }, (decisionAid) =>
      @decisionAid = decisionAid
    , (error) =>
      @handleError(error)

  # MARK - Not implemented yet
  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  deleteOptionProperty: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this option property?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      if !@option.has_sub_options
        @optionProperty.$delete({decision_aid_id: @$stateParams.decisionAidId}, 
          (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), 
          ((error) => @handleError(error))
        )

  saveOptionProperty: () ->
    if @option.has_sub_options
      @OptionProperty.updateBulk(@optionProperties, @$stateParams.decisionAidId).then (ops) =>
        @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})
      , (error) => 
        @errors = @_.map error.errors?.option_properties, (k, v) => @_.map(k, (kk) => kk).join(",")
    else
      if @isNewOptionProperty
        @optionProperty.$save({decision_aid_id: @$stateParams.decisionAidId}, 
          (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), 
          ((error) => @handleError(error))
        )
      else
        @optionProperty.$update({decision_aid_id: @$stateParams.decisionAidId}, 
          (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), 
          ((error) => @handleError(error))
        )


module.controller 'OptionPropertyEditCtrl', OptionPropertyEditCtrl

