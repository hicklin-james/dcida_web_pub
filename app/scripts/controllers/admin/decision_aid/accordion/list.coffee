'use strict'

module = angular.module('dcida20App')

class AccordionListCtrl
  @$inject: ['$scope', '$state', '$uibModalInstance', 'options', 'Accordion', 'moment', 'userId', 'Auth', '$q', 'Confirm', '_', '$timeout']
  constructor: (@$scope, @$state, @$uibModalInstance, options, @Accordion, @moment, userId, @Auth, @$q, @Confirm, @_, @$timeout) ->
    @$scope.ctrl = @
    @loading = true
    @userId = @Auth.currentUserId()
    @decisionAidId = options.decisionAidId
    @currentlyEditing = new @Accordion
    @currentlyEditing.initialize()
    @garbageBin = []


    @colorMap = [
                  key: "primary"
                  value: "#337ab7" 
                 ,
                  key: "success"
                  value: "#dff0d8" 
                 ,
                  key: "info"
                  value: "#d9edf7"
                 ,
                  key: "warning"
                  value: "#fcf8e3"
                 ,
                  key: "danger"
                  value: "#f2dede"
                 ,
                  key: "default"
                  value: "white"
                ]

    @Accordion.query {decision_aid_id: @decisionAidId}, (accordions) =>
      @accordions = accordions

  setAccordionPanelOrders: () ->
    @_.each @currentlyEditing.accordion_contents, (ac, index) ->
      ac.order = index

  editAccordion: (accordion) ->
    @currentlyEditing = accordion
    @garbageBin = []
    @saved = false

  addNewPanel: () ->
    newAccordionContent = {}
    @currentlyEditing.accordion_contents.push newAccordionContent

  expand: (ac) ->
    ac.expanded = true

  unexpand: (ac) ->
    ac.expanded = false

  destroyPanel: (panel) ->
    i = @_.indexOf @currentlyEditing.accordion_contents, panel
    if i > -1
      @currentlyEditing.accordion_contents.splice i, 1
    if panel.id
      @garbageBin.push panel.id

  save: (acc) ->
    d = @$q.defer()

    @setAccordionPanelOrders()
    @currentlyEditing.sanitizeForSubmit()

    if @currentlyEditing.id?
      @currentlyEditing.$update {decision_aid_id: @decisionAidId, "garbage_bin[]": @garbageBin}, (acc) =>
        @setSaved()
        @currentlyEditing.accordion_contents = @_.sortBy @currentlyEditing.accordion_contents, 'order'
        @garbageBin = []
        d.resolve(acc)
      ,(error) =>
        d.reject()
    else
      @currentlyEditing.$save {decision_aid_id: @decisionAidId}, (acc) =>
        @accordions.push acc
        @currentlyEditing.accordion_contents = @_.sortBy @currentlyEditing.accordion_contents, 'order'
        @setSaved()
        @garbageBin = []
        d.resolve(acc)
      ,(error) =>
        d.reject()

    d.promise

  destroy: (acc) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this accordion?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      if @currentlyEditing is acc
        @new()
      acc.$delete {decision_aid_id: @decisionAidId}, () =>
        i = @_.indexOf @accordions, acc
        if i > -1
          @accordions.splice i, 1

  cancel: () ->
    @$uibModalInstance.dismiss('cancel')

  setSaved: () ->
    @saved = true
    @$timeout () =>
      @saved = false
    , 2000

  insert: () ->
    @save().then (acc) =>
      @$uibModalInstance.close(acc)

  insertAccordion: (acc) ->
    acc.$update {decision_aid_id: @decisionAidId}, (acc) =>
      @$uibModalInstance.close(acc)

  new: () ->
    @saved = false
    acc = new @Accordion
    acc.initialize()
    @currentlyEditing = acc
    @garbageBin = []


module.controller 'AccordionListCtrl', AccordionListCtrl

