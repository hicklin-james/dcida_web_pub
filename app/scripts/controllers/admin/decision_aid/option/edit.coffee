'use strict'

module = angular.module('dcida20App')

module.filter 'radioAndYesNo', (_) ->
  (questions) ->
    _.filter questions, (q) => q.question_response_type is 'radio' or q.question_response_type is 'yes_no'


class OptionEditCtrl
  @$inject: ['$scope', '$rootScope', '$state', 'SubDecision', '$uibModal', '$stateParams', 'DecisionAid', 'Option', 'Question', 'Confirm', '_', '$q']
  constructor: (@$scope, @$rootScope, @$state, @SubDecision, @$uibModal, @$stateParams, @DecisionAid, @Option, @Question, @Confirm, @_, @$q) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId
    @subDecisionId = @$stateParams.sub_decision_id

    if @$stateParams.id
      @isNewOption = false
      @title = "Edit Option"
      @getOption @$stateParams.id
    else
      @isNewOption = true
      @title = "New Option"
      @option = new @Option
      @option.initialize(@$stateParams.decisionAidId, @subDecisionId)
      @currentlyEditing = @option
      @getQuestions()

  getOption: (id) ->
    @Option.get { id: id, decision_aid_id: @$stateParams.decisionAidId }
    , (option) =>
      @option = option
      @initialHasSubOptions = angular.copy option.has_sub_options
      @currentlyEditing = @option
      @getQuestions()

  selectAllQuestionResponses: (item = @currentlyEditing) ->
    @_.each item.questions_with_responses, (q) =>
      @_.each q.question_responses, (qr) =>
        qr.selected = true

  selectNoQuestionResponses: (item = @currentlyEditing) ->
    @_.each item.questions_with_responses, (q) =>
      @_.each q.question_responses, (qr) =>
        qr.selected = false

  hasSubOptionsChanged: () ->
    if @option.has_sub_options is false
      @option.questions_with_responses = angular.copy @questions
      @option.setupQuestionResponses()
      @currentlyEditing = @option
    else
      if @option.sub_options.length > 0
        @currentlyEditing = @option.sub_options[0]
      else
        @addSubOption()

  allQuestionsSelected: (item = @currentlyEditing) ->
    @_.all item.questions_with_responses, (q) => @_.all q.question_responses, (qr) => qr.selected
  
  noQuestionsSelected: (item = @currentlyEditing) ->
    @_.all item.questions_with_responses, (q) => @_.all q.question_responses, (qr) => !qr.selected

  setupSubOptions: () ->
    @_.each @option.sub_options, (o, i) =>
      o = new @Option(o)
      o.questions_with_responses = angular.copy @questions
      o.setupQuestionResponses()
      @option.sub_options[i] = o
      
    @option.questions_with_responses = angular.copy @questions
    @option.setupQuestionResponses()

    if @option.has_sub_options
      if @option.sub_options.length > 0
        @currentlyEditing = @option.sub_options[0]
      else
        @addSubOption()
    else
      @currentlyEditing = @option

  getQuestions: () ->
    @Question.query { decision_aid_id: @$stateParams.decisionAidId, include_responses: true, question_type: "demographic", question_response_type: "radio,grid,yes_no" }, (questions) =>
      @questions = @Question.flattenQuestions(questions)
      #console.log @questions
      @setupSubOptions()

      if @option.sub_decision_id
        @loading = false
      else
        @getSubDecisions()

  getSubDecisions: () ->
    @SubDecision.query {decision_aid_id: @decisionAidId}, (subDecisions) =>
      @subDecisions = subDecisions
      @loading = false

  deleteOption: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this option?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @option.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))

  openImagePicker: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/image_picker.html"
      controller: "ImagePickerCtrl"
      size: 'md-lg'
      backdrop: 'static'
      resolve: 
        options: () =>
          selectedFileId: @currentlyEditing.media_file_id
    )

    modalInstance.result.then (image) =>
      @currentlyEditing.image = image.image
      @currentlyEditing.image_thumb = image.thumb
      @currentlyEditing.media_file_id = image.id

  removeImage: () ->
    @currentlyEditing.image = null
    @currentlyEditing.image_thumb = null
    @currentlyEditing.media_file_id = null

  optionQuestionComparitor: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/question_comparitor.html"
      controller: "QuestionComparitorCtrl"
      size: 'lg'
      resolve:
        options: () =>
          questions: @questions
          option: @option
    )

  addSubOption: () ->
    subOption = new @Option
    subOption.initialize(@$stateParams.decisionAidId, true)
    subOption.copyAttributes(@option)
    subOption.label = "#{@option.title} - sub-option #{@option.sub_options.length + 1}"
    subOption.questions_with_responses = angular.copy @questions  #@Question.flattenQuestions(angular.copy @questions)
    #console.log subOption.questions_with_responses
    subOption.setupQuestionResponses()
    
    @option.sub_options.push(subOption)
    #@setupSubOptions()
    @currentlyEditing = subOption

  # MARK - Not implemented yet
  handleError: (error) ->
    @setupSubOptions()
    if data = error.data
      if errors = data.errors
        @errors = errors
        @loading = false

  hasSubOptionsTrue: () ->
    @Confirm.show(
      message: 'Warning'
      messageSub: "You changed this option to have sub options. 
        This will delete any option properties associated with this option. 
        Are you sure you want to continue?"
      buttonType: 'danger'
      confirmText: 'Yes'
    )

  hasSubOptionsFalse: () ->
    @Confirm.show(
      message: 'Warning'
      messageSub: "You changed this option to no longer have sub options. 
        This will delete any option properties associated with the sub options, and the sub options themeselves. 
        Are you sure you want to continue?"
      buttonType: 'danger'
      confirmText: 'Yes'
    )

  validateQuestionResponses: () ->
    flag = true
    d = @$q.defer()
    if @option.has_sub_options
      flag = !@_.some @option.sub_options, (o) =>
        @_.some o.questions_with_responses, (q) =>
          if q.question_response_type isnt 'radio' and q.question_response_type isnt 'yes_no'
            false
          else
            @_.every q.question_responses, (qr) =>
              !qr.selected
      if !flag
        @errors = ["One of your sub-options has a question response combination that makes the sub-option
                  impossible to show. Ensure that each question has at least one question response ticked
                  for every sub-option."]
    else
      flag = !@_.some @option.questions_with_responses, (q) =>
        if q.question_response_type isnt 'radio' and q.question_response_type isnt 'yes_no'
          false
        else
          @_.every q.question_responses, (qr) =>
            !qr.selected
      if !flag
        @errors = ["Your option has a question response combination that makes the option 
                  impossible to show. Ensure that each question has at least one question response ticked."]
    flag


  saveOption: () ->
    @option.updateQuestionResponses()
    if @option.has_sub_options
      @_.each @option.sub_options, (o) =>
        o.updateQuestionResponses()
        o.title = @option.title
        o.generic_name = @option.generic_name
    else
      @option.sub_options = []
    if @validateQuestionResponses()
      @option.prepareForSubmit()
      if @isNewOption
        @option.$save {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
      else
        if @initialHasSubOptions isnt @option.has_sub_options
          if @option.has_sub_options is true
            @hasSubOptionsTrue().result.then () =>
              @option.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
          else
            @hasSubOptionsFalse().result.then () =>
              @option.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))
        else
            @option.$update {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.myOptions", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))


module.controller 'OptionEditCtrl', OptionEditCtrl

