'use strict'

module = angular.module('dcida20App')


class DecisionAidEditMyOptionsCtrl
  @$inject: ['$scope', '$state', 'Sortable', '$stateParams', '_', 'Option', 'OptionProperty', 'Property', 'DecisionAid', 'Confirm', 'AdminTabHelper', '$q', '$uibModal', 'ErrorHandler']
  constructor: (@$scope, @$state, @Sortable, @$stateParams, @_, @Option, @OptionProperty, @Property, @DecisionAid, @Confirm, @AdminTabHelper, @$q, @$uibModal, @ErrorHandler) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid     = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @saveSuccess = false

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    
    @loading = true

    p1 = @Option.query({decision_aid_id: @$stateParams.decisionAidId}, (options) => 
      @options =  options #@_.groupBy options, 'sub_decision_id'
      @groupedOptions = @_.groupBy options, 'sub_decision_id'
    ).$promise

    p2 = @Property.query({decision_aid_id: @$stateParams.decisionAidId}, (properties) => 
      @properties = properties
    ).$promise

    p3 = @OptionProperty.query({decision_aid_id: @$stateParams.decisionAidId}, (optionProperties) =>
      @optionPropertiesHash = @OptionProperty.createOptionPropertiesHash(optionProperties)
    ).$promise

    # combine queries and only stop loading when all promises have resolved
    promises = [p1, p2, p3]

    @$q.all(promises).then () =>
      optionsWithSubOptions = @_.filter @options, (o) => o.has_sub_options
      @subOptionProps = {}
      #console.log @options
      
      @setupOptions()
      @loading = false

  setupOptions: () ->
    @_.each @groupedOptions, (os) =>
      @_.each os, (o) =>
        if o.has_sub_options
          @_.each @properties, (p) =>
            count = 0
            @_.each o.sub_option_ids, (soid) =>
              count += 1 if @optionPropertiesHash[soid]?[p.id]?
            @optionPropertiesHash[o.id] = {} if !@optionPropertiesHash[o.id]?
            @optionPropertiesHash[o.id][p.id] = if count is o.sub_option_ids.length then {complete: true} else {complete: false}
    @optionPropertiesHashCopy = angular.copy @optionPropertiesHash

  onOptionSort: (option, partFrom, partTo, indexFrom, indexTo) ->
    if option and option.option_order isnt indexTo + 1
      option.option_order = indexTo + 1
      @reorderItem(option, @groupedOptions[option.sub_decision_id], "option_order")

  onPropertySort: (prop, partFrom, partTo, indexFrom, indexTo) ->
    if prop and prop.property_order isnt indexTo + 1
      prop.property_order = indexTo + 1
      @reorderItem(prop, @properties, "property_order")

  cloneOption: (option) ->
    option.clone().then (cloned_option) =>
      @Confirm.alert(
        message: "Success!"
        messageSub: "The option was successfully cloned"
        buttonType: "default"
        headerClass: "text-success"
      )
      @Sortable.addToItemArray new @Option(cloned_option), @options, "option_order"
      @Sortable.addToItemArray new @Option(cloned_option), @groupedOptions[cloned_option.sub_decision_id], "option_order"
      #@addToItemArray(new @Option(cloned_option), "option_order", "options")

  cloneProperty: (property) ->
    property.clone().then (cloned_property) =>
      @Confirm.alert(
        message: "Success!"
        messageSub: "The property was successfully cloned"
        buttonType: "default"
        headerClass: "text-success"
      )
      @Sortable.addToItemArray new @Property(cloned_property), @properties, "property_order"
      #@addToItemArray(new @Property(cloned_property), "property_order", "properties")

  deleteOption: (option) ->
    oc = angular.copy option
    @Confirm.show(
      message: 'Are you sure you want to delete this option?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      option.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        #console.log oc
        @Sortable.finishItemDeletion(option, @options, "option_order")
        @Sortable.finishItemDeletion(option, @groupedOptions[oc.sub_decision_id], "option_order")
        #@finishItemDeletion(option, "options", "option_order")
     ),((error) => 
        alert("Option deletion failed")
      )

  deleteProperty: (property) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this property?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      property.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        @Sortable.finishItemDeletion(property, @properties, "property_order")
       # @finishItemDeletion(property, "properties", "property_order")
     ),((error) => 
        alert("Property deletion failed")
      )

  reorderItem: (item, array, orderName) ->
    @Sortable.reorderItem(item, array, orderName)

  saveAndPreview: (n) ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview(@decisionAid, n)
    else
      @preview(@decisionAid, n)


  preview: (da, n) ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/my_options.html"
      controller: "MyOptionsPreviewCtrl"
      size: 'lg'
      resolve:
        options: () =>
          value:        n
          decisionAid:  @decisionAid
          id:           @decisionAid.id
          title:        @decisionAid.title
          subDecisions: @decisionAid.sub_decisions
    )

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))

module.controller 'DecisionAidEditMyOptionsCtrl', DecisionAidEditMyOptionsCtrl

