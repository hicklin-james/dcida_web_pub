'use strict'

module = angular.module('dcida20App')

class PropertyEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', '$stateParams', 'DecisionAid', 'Property', 'Confirm', 'Sortable', '$q']
  constructor: (@$scope, @$state, @$uibModal, @$stateParams, @DecisionAid, @Property, @Confirm, @Sortable, @$q) ->
    @$scope.ctrl = @
    @deletedPropertyLevels = []
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId
    
    promises = []

    if @$stateParams.id
      @isNewProperty = false
      @title = "Edit Property"
      promises.push @getProperty(@$stateParams.id).$promise
    else
      @isNewProperty = true
      @title = "New Property"
      @property = new @Property
      @property.title = ""
      @property.property_levels = []

    promises.push @getDecisionAid().$promise

    @$q.all(promises).then () =>
      @loading = false

  getDecisionAid: () ->
    @DecisionAid.get {id: @$stateParams.decisionAidId }, (decisionAid) =>
      @decisionAid = decisionAid
      @levelsActive = decisionAid.decision_aid_type is 'dce' or 
                      decisionAid.decision_aid_type is 'best_worst' or 
                      decisionAid.decision_aid_type is "best_worst_no_results" or
                      decisionAid.decision_aid_type is "dce_no_results" or
                      decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"

  getProperty: (id) ->
    @Property.get { id: id, decision_aid_id: @$stateParams.decisionAidId }
    , (property) =>
      @property = property

  deleteProperty: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this property?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @property.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))

  addPropertyLevel: () ->
    newPropertyLevel = 
      level_id: @property.property_levels.length + 1
      decision_aid_id: @$stateParams.decisionAidId
    @Sortable.addToItemArray newPropertyLevel, @property.property_levels, 'level_id'

  deletePropertyLevel: (propertyLevel) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this property level?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      if propertyLevel.id
        propertyLevel._destroy = 1
        @deletedPropertyLevels.push propertyLevel
      @Sortable.finishItemDeletion(propertyLevel, @property.property_levels, 'level_id')
  
  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  saveProperty: () ->
    @property.preparePropertyLevelsForUpload(@deletedPropertyLevels)
    if @isNewProperty
      @property.$save {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        if @decisionAid.decision_aid_type isnt "best_worst_no_results" and @decisionAid.decision_aid_type isnt "dce_no_results"
          @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})
        else
          @$state.go("decisionAidShow.propertiesNoResults", {decisionAidId: @$stateParams.decisionAidId})
        ), ((error) => @handleError(error))
    else
      @property.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        if @decisionAid.decision_aid_type isnt "best_worst_no_results" and @decisionAid.decision_aid_type isnt "dce_no_results"
          @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})
        else
          @$state.go("decisionAidShow.propertiesNoResults", {decisionAidId: @$stateParams.decisionAidId})
        ), ((error) => @handleError(error))


module.controller 'PropertyEditCtrl', PropertyEditCtrl

