'use strict'

module = angular.module('dcida20App')

module.filter 'filteredQuestions', (_) ->
  (questions, filterArray, currentSelection) ->
    _.reject questions, (q) -> q.id isnt currentSelection and filterArray.indexOf(q.id) > -1

class QuestionEditCtrl
  @$inject: ['$scope', '$state', '$uibModal', '$stateParams', 'DecisionAid', 'SubDecision', 'Question', '_', 'Confirm', 'Option', 'SkipLogicTarget', '$q', 'QuestionPage']
  constructor: (@$scope, @$state, @$uibModal, @$stateParams, @DecisionAid, @SubDecision, @Question, @_, @Confirm, @Option, @SkipLogicTarget, @$q, @QuestionPage) ->
    @$scope.ctrl = @
    @decisionAidId = @$stateParams.decisionAidId
    @redcapConnectionSuccess = 2

    @hidden = @$state.current.name == "questionNewHidden" or @$state.current.name == "questionEditHidden"

    @showErrors = false
    @loading = true
    @decisionAidId = @$stateParams.decisionAidId
    @questionPageId = @$stateParams.questionPageId

    @gridQrts = [
      key: "Radio"
      value: "radio"
     ,
      key: "Yes/No"
      value: "yes_no"
    ]

    @remoteDataSourceTypes = [
      key: "REDCap"
      value: "redcap"
     ,
      key: "MySQL"
      value: "my_sql"
      disabled: true
     ,
      key: "Chatbot"
      value: "chatbot"
    ]

    @remoteDataTargetTypes = [
      key: "REDCap"
      value: "redcap_t"
    ]

    @mysqlParamSources = [
      key: "Question Response"
      value: "question_response"
     ,
      key: "Input"
      value: "input"
    ]

    currVal = null

    @lookupTableDimensions = []

    @destroyedQuestionResponses = []
    @destroyedGridQuestions = []


    promises = [@getDecisionAidPages()]

    if @$stateParams.id
      @isNewQuestion = false
      @title = "Edit Question"
      promises.push(@getQuestion(@$stateParams.id).$promise)
    else
      @isNewQuestion = true
      @title = "New Question"
      @question = new @Question
      #@question.skip_logic_targets = []
      @question.units_array = []
      @question.question_type = @$stateParams.questionType
      @question.question_responses = []
      @question.grid_questions = []
      @question.lookup_table_dimensions = []
      @question.skippable = false
      @question.can_change_response = true
      @question.special_flag = "normal"
      @question.decision_aid_id = @decisionAidId
      @question.question_page_id = @questionPageId
      @question.redcapConnectionSuccess = 2
      @question.hidden = @$state.current.name == "questionNewHidden" or @$state.current.name == "questionEditHidden"
      @gridResponses = []

    if @$stateParams.questionType or @title is "Edit Question"
      @questionTypeSet = true

    @$q.all(promises).then (resolvedPromises) =>
      @pageTargets = resolvedPromises[0]?.pages
      @setPageTargets()
      if resolvedPromises.length > 1
        @question = resolvedPromises[1]
        @question.redcapConnectionSuccess = 2
        if @question.grid_questions.length > 0
          @gridResponses = angular.copy @question.grid_questions[0].question_responses
          #console.log @gridResponses
          @gridQrt = angular.copy @question.grid_questions[0].question_response_type
          @_.each @gridResponses, (r) ->
            delete r.id
          @_.each @question.grid_questions, (q, i) =>
            @question.grid_questions[i] = new @Question(q)
            @question.grid_questions[i].redcapConnectionSuccess = 2
        else
          @gridResponses = []

        if @question.question_response_type isnt "json"
          rt = @_.find @questionResponseTypes, (qrt) => qrt.value is "json"
          if rt
            rt.disabled = true

        # @buildDeletedSkipLogicConditions()
        # @buildDeletedSkipLogicTargets()

        if @question.question_response_type is 'lookup_table'
          @getRadioQuestions()
        else if @question.question_response_type is "current_treatment"
          @getSubDecisions()
        else
          @loading = false
      else
        @loading = false

    @questionTypes = [
      {
        key: 'Demographic',
        value: 'demographic'
      }
     ,{
        key: 'Quiz',
        value: 'quiz'
     }
    ]

    @questionResponseTypes = [
      {
        key: 'Radio',
        value: 'radio'
      }
     ,{
        key: 'Text',
        value: 'text'
     }
     ,{
        key: 'Grid',
        value: "grid",
        disabled: @hidden
     }
     ,{
        key: 'Number',
        value: 'number'
     }
     ,{
      key: 'Lookup Table',
      value: 'lookup_table',
      disabled: !@hidden
     }
     ,{
      key: 'Yes/No',
      value: 'yes_no'
     }
     ,{
      key: 'Slider',
      value: 'slider',
      disabled: @hidden
     }
     ,{
      key: 'Ranking',
      value: 'ranking',
      disabled: @hidden
     }
     ,{
      key: "Heading",
      value: "heading",
      disabled: @hidden
     }
     ,{
      key: "Sum to N",
      value: "sum_to_n"
     }
     ,{
      key: "Current Treatment",
      value: 'current_treatment',
      disabled: @hidden
     }
     ,{
      key: "JSON",
      value: "json",
      disabled: @isNewQuestion    
     }
    ]

    @questionResponseSkips = [
      {
        key: "Skip to question page",
        value: "question_page"
      },
      {
        key: "Skip to end of section",
        value: "end_of_questions"
      },
      {
        key: "Skip to external page",
        value: "external_page"
      },
      {
        key: "Skip to other section",
        value: "other_section"
      }
    ]

    @questionResponseStyles =
      radio:
        default: "horizontal_radio"
        styles: [
          name: "Horizontal Radio"
          value: "horizontal_radio"
         ,
          name: "Vertical Radio"
          value: "vertical_radio"
         ,
          name: "Dropdown Radio"
          value: "dropdown_radio"
        ]
      text:
        default: "normal_text"
        styles: [
          name: "Default"
          value: "normal_text"
        ]
      grid:
        default: "normal_grid"
        styles: [
          name: "Default"
          value: "normal_grid"
        ]
      number:
        default: "normal_number"
        styles: [
          name: "Default"
          value: "normal_number"
        ]
      lookup_table:
        default: "normal_lookup_table"
        styles: [
          name: "Default"
          value: "normal_lookup_table"
        ]
      yes_no:
        default: "normal_yes_no"
        styles: [
          name: "Default"
          value: "normal_yes_no"
        ]
      current_treatment:
        default: "normal_current_treatment"
        styles: [
          name: "Default"
          value: "normal_current_treatment"
        ]
      json:
        default: "normal_json"
        styles: [
          name: "Default"
          value: "normal_json"
        ]
      heading:
        default: "normal_heading"
        styles: [
          name: "Default"
          value: "normal_heading"
        ]
      ranking:
        default: "normal_ranking"
        styles: [
          name: "Default"
          value: "normal_ranking"
        ]
      sum_to_n:
        default: "horizontal_sum_to_n",
        styles: [
          name: "Horizontal"
          value: "horizontal_sum_to_n"
        ,
          name: "Vertical"
          value: "vertical_sum_to_n"
        ,
          name: "Stacking"
          value: "stacking_sum_to_n"
        ]
      slider:
        default: "horizontal_slider"
        styles: [
          name: "Horizontal"
          value: "horizontal_slider"
        ,
         name: 'Vertical'
         value: "vertical_slider"
        ]

  setPageTargets: () ->

    capitalize = (s) =>
      if typeof s isnt 'string'
        return ''
      return s.charAt(0).toUpperCase() + s.slice(1)

    @skipSectionTargets = @_.map @pageTargets, (pt) =>
      {
        key: @_.map(pt.split("_"), (word) => capitalize(word)).join(" "),
        value: pt
      }

  getDecisionAidPages: () ->
    @DecisionAid.getPages(@decisionAidId)

  getRadioQuestions: () ->
    @Question.query { decision_aid_id: @$stateParams.decisionAidId, include_responses: true, question_response_type: "radio,yes_no" }, (questions) =>
      @radioQuestions = questions
      @radioQuestionHash = @_.indexBy questions, 'id'
      @generatePermutations()
      @tempLookupTable = {}
      @generateTempLookupTable([], @question.lookup_table)
      @loading = false

  # buildDeletedSkipLogicConditions: () ->
  #   @deletedSkipLogicConditions = {}
  #   @_.each @question.skip_logic_targets, (slt) =>
  #     @deletedSkipLogicConditions[slt.id] = []

  # buildDeletedSkipLogicTargets: () ->
  #   @deletedSkipLogicTargets = []

  generateTempLookupTable: (currArr, val) ->
    @_.each val, (v, k) =>
      cp = angular.copy(currArr)
      cp.push(k)
      if v isnt null && typeof v is 'object'
        @generateTempLookupTable(cp, v)
      else
        @tempLookupTable[cp] = v
      # if !isNaN(v)
      #   @tempLookupTable[cp] = v
      # else
      #   @generateTempLookupTable(cp, v)

  testRedcapConnection: (q) ->
    q.redcapConnectionSuccess = 4
    @question.testRedcapQuestion(q.redcap_field_name).then (data) =>
      q.redcapConnectionSuccess = 1
    , (error) =>
      q.redcapConnectionSuccess = 3

  addUnit: () ->
    @question.units_array.push ""

  removeUnit: (index) ->
    @question.units_array.splice(index, 1)

  getQuestion: (id) ->
    @Question.get({ id: id, decision_aid_id: @$stateParams.decisionAidId })

  responseSkipLogicTargetChanged: (qr) ->
    if qr.skip_logic_targets[0].target_entity is "question_page"
      if !@questionPages
        @getQuestionPageData()

  gridResponseSort: (item, from, to, ifrom, ito) ->
    #console.log @question.grid_questions
    @_.each @question.grid_questions, (q) =>
      undeletedResponses = @_.filter q.question_responses, (qr) -> qr._destroy isnt 1
      deletedResponses = @_.filter q.question_responses, (qr) -> qr._destroy is 1
      #console.log undeletedResponses
      undeletedResponses.splice(ito, 0, undeletedResponses.splice(ifrom, 1)[0])
      #console.log undeletedResponses
      @_.each undeletedResponses, (qr, i) =>
        qr.question_response_order = i + 1

      q.question_responses = undeletedResponses.concat(deletedResponses)
      #console.log q.question_responses

  markQuestionResponseForDestruction: (qr) ->
    i = @_.indexOf @question.question_responses, qr
    qr._destroy = 1
    if i > -1
      destroyedQuestionResponse = @question.question_responses.splice i, 1
      if qr.id?
        @destroyedQuestionResponses.push destroyedQuestionResponse[0]

  markGridQuestionResponseForDestruction: (qr) ->
    i = @_.indexOf @gridResponses, qr
    if i > -1
      @_.each @question.grid_questions, (q, ind) =>
        r = q.question_responses[i]
        if r.id?
          r._destroy = 1
        else
          q.question_responses.splice i, 1
          if ind is 0
            @gridResponses.splice i, 1
      qr._destroy = 1
    
    # if !qr.id?
    #   @gridResponses.splice i, 1

    #console.log @gridResponses
    #console.log @question.grid_questions

  setQuestionResponseOrders: () ->
    @_.each @question.question_responses, (qr, index) ->
      qr.question_response_order = index

  addNewQuestionResponse: () ->
    newQr = {}
    newQr.decision_aid_id = @$stateParams.decisionAidId
    @question.question_responses.push newQr

  # openQuestionPicker: (qr) ->
  #   if @question.question_type
  #     modalInstance = @$uibModal.open(
  #       templateUrl: "views/admin/shared/question_picker.html"
  #       controller: "QuestionPickerCtrl"
  #       size: 'lg'
  #       resolve:
  #         options: () =>
  #           decisionAidId: @decisionAidId
  #           questionType: @question.question_type
  #           flatten: false
  #           includeHidden: false
  #           gridSelectable: true
  #           questionResponseType: 'radio,text,number,yes_no,grid,current_treatment,heading,slider,ranking'
  #           descriptionText: 'Select a question from the list of questions.'
  #     )

  #     modalInstance.result.then (question) =>
  #       qr.skip_logic_targets[0].skip_question_id = question.id

  questionResponseTypeChanged: () ->
    if @question.question_response_type isnt 'radio' and @question.question_response_type isnt 'number' and @question.question_response_type isnt "yes_no" and @question.question_response_type isnt "text"

      @question.hidden = false
      @question.response_value_calculation = ""
    
    if @question.question_response_type isnt 'radio' and @question.question_response_type isnt 'yes_no'
      @question.remote_data_source = false

    if @question.question_response_type is "yes_no"
      @_.each @question.question_responses, (qr) =>
        if qr.id?
          qr._destroy = 1
          @destroyedQuestionResponses.push qr
      @question.question_responses = []
      qr1 = {}
      qr1.decision_aid_id = @$stateParams.decisionAidId
      qr1.question_response_order = 1
      qr1.question_response_value = "Yes"
      @question.question_responses.push qr1
      qr2 = {}
      qr2.decision_aid_id = @$stateParams.decisionAidId
      qr2.question_response_order = 2
      qr2.question_response_value = "No"
      @question.question_responses.push qr2

    if @question.question_response_type is "radio" or 
       @question.question_response_type is "ranking" or
       @question.question_response_type is "sum_to_n"
       
      @_.each @question.question_responses, (qr) =>
        if qr.id?
          qr._destroy = 1
          @destroyedQuestionResponses.push qr
      @question.question_responses = []

    if @question.question_response_type is "grid"
      @gridQrt = "radio"

    if @question.question_response_type is 'lookup_table'
      @getRadioQuestions()
      @question.hidden = true

    if @question.question_response_type is "current_treatment"
      @getSubDecisions()

    @question.question_response_style = @questionResponseStyles[@question.question_response_type].default

  skipLogicActivatedForQuestionResponse: (qr) ->
    if qr.has_skip_logic
      if qr.deletedSkipLogicTarget
        delete qr.deletedSkipLogicTarget._destroy
        qr.skip_logic_targets = [qr.deletedSkipLogicTarget]
      else
        qr.skip_logic_targets = [@SkipLogicTarget.buildSkipLogicTarget(@decisionAidId)]
    else
      if qr.skip_logic_targets[0]
        if qr.skip_logic_targets[0].id
          qr.deletedSkipLogicTarget = qr.skip_logic_targets[0]
          qr.deletedSkipLogicTarget._destroy = 1
          qr.skip_logic_targets = []
        else
          qr.skip_logic_targets = []

  getQuestionPageData: () ->
    section = if @question.question_type is "demographic" then "about" else "quiz"
    @QuestionPage.query {decision_aid_id: @decisionAidId, section: section}, (questionPages) =>
      @questionPages = questionPages
      @_.each @questionPages, (qp) =>
        qp.name = "Question Page " + qp.question_page_order

  getSubDecisions: () ->
    if !@subDecisions
      @SubDecision.query { decision_aid_id: @$stateParams.decisionAidId }, (subDecisions) =>
        @Option.query { decision_aid_id: @$stateParams.decisionAidId }, (options) =>
          @subDecisions = subDecisions
          os = @_.map options, (o) =>
            o.selected = (@question.current_treatment_option_ids.indexOf(o.id) >= 0)
            o
          @options = @_.groupBy(os, "sub_decision_id")

          if !@question.sub_decision_id
            @question.sub_decision_id = subDecisions[0].id
          @loading = false

  #subDecisionChanged: () ->
  #  console.log("HEY!")

  gridQrtChanged: () ->
    if @gridQrt is 'yes_no'
      @gridResponses = []
      qr1 = {}
      qr1.decision_aid_id = @$stateParams.decisionAidId
      qr1.question_response_order = 1
      qr1.question_response_value = "Yes"
      @gridResponses.push qr1
      qr2 = {}
      qr2.decision_aid_id = @$stateParams.decisionAidId
      qr2.question_response_order = 2
      qr2.question_response_value = "No"
      @gridResponses.push qr2
      
      # @_.each @question.grid_questions, (q) =>
      #   @_.each q.question_responses, (qr) =>
      #     qr._destroy = 1
    
    else
      @gridResponses = []

  addNewGridQuestion: () ->
    q = new @Question
    q.decision_aid_id = @$stateParams.decisionAidId
    q.redcapConnectionSuccess = 2
    #q.question_response_type = "radio"
    q.question_responses = angular.copy @gridResponses
    @question.grid_questions.push q

  deleteGridQuestion: (q) ->
    i = @_.indexOf @question.grid_questions, q
    q._destroy = 1
    if i > -1
      destroyedGridQuestion = @question.grid_questions.splice i, 1
      if q.id?
        @destroyedGridQuestions.push destroyedGridQuestion[0]

  addNewGridResponse: () ->
    newQr = {}
    newQr.decision_aid_id = @$stateParams.decisionAidId
    newQr.question_response_order = @gridResponses.length + 1
    @gridResponses.push newQr
    @_.each @question.grid_questions, (q) =>
      q.question_responses.push (angular.copy newQr)

  setGridQuestionOrders: () ->
   @_.each @question.grid_questions, (q, index) ->
    q.question_order = index + 1

  deleteQuestion: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this question?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @question.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => @$state.go("decisionAidShow.aboutMe", {decisionAidId: @$stateParams.decisionAidId})), ((error) => @handleError(error))

  handleError: (error) ->
    if data = error.data
      if errors = data.errors
        @errors = errors

  # openSkipLogicEditor: () ->
  #   modalInstance = @$uibModal.open(
  #     templateUrl: "views/admin/shared/skip_logic_editor.html"
  #     controller: "SkipLogicEditorCtrl"
  #     size: 'lg'
  #     resolve:
  #       options: () =>
  #         decisionAidId: @decisionAidId
  #         question: @question
  #         deletedSkipLogicConditions: @deletedSkipLogicConditions
  #         deletedSkipLogicTargets: @deletedSkipLogicTargets
  #     )

  #   modalInstance.result.then (response) =>
  #     @question.skipLogicTargets = response.skipLogicTargets
  #     @deletedSkipLogicConditions = response.deletedSkipLogicConditions
  #     @deletedSkipLogicTargets = response.deletedSkipLogicTargets

  goBack: (question) ->
    if question.question_type is "demographic"
      @$state.go 'decisionAidShow.aboutMe', {decisionAidId: @$stateParams.decisionAidId}
    else
      @$state.go 'decisionAidShow.quiz', {decisionAidId: @$stateParams.decisionAidId}

  changedLookupValAtIndex: (index) ->
    if !@question.lookup_table_dimensions[index]
      @question.lookup_table_dimensions.splice(index, 1)
    @question.lookup_table = {}
    @generatePermutations()
    # selectedQuestions = @_.filter @questions, (q) => @question.lookup_table_dimensions.indexOf(q.id) > -1
    # permutations = @permutator(selectedQuestions)
    #console.log permutations

  valueFromPerm: (perm) ->
    val = @question.lookup_table
    @_.each perm, (dim) =>
      if val[dim.id]
        val = val[dim.id]
      else
        return null
    val

  modelFromPerm: (perm) ->
    last = @question.lookup_table
    @_.each perm, (dim, ind) =>
      if ind is perm.length - 1
        last[dim.id] = null
      else if !last[dim.id]
        last[dim.id] = {}
      last = dim
    last

  generatePermutations: () ->
    selectedResponses = @_.map @_.sortBy(@_.filter(@radioQuestions, (q) => @question.lookup_table_dimensions.indexOf(q.id) > -1), (q) => @question.lookup_table_dimensions.indexOf(q.id)), (q) => q.question_responses
    
    #args = @_.map selectedQuestions, (q) -> q.responses
    @perms = @cartesian(selectedResponses)

  cartesian: (arg) ->
    r = []
    #arg = arguments
    return [] if arg.length is 0
    max = arg.length - 1

    helper = (arr, i) ->
      j = 0
      l = arg[i].length
      while j < l
        a = arr.slice(0)
        # clone arr
        a.push arg[i][j]
        if i == max
          r.push a
        else
          helper a, i + 1
        j++
      return

    helper [], 0
    r  

  fixLookupTable: () ->
    lookupTable = {}
    if @tempLookupTable
      @_.each @tempLookupTable, (v, k) ->
        keys = k.split(',')
        i = 0
        temp = lookupTable
        while i < keys.length
          currKey = keys[i]
          if i is keys.length - 1
            temp[currKey] = v
          if !temp[currKey]
            temp[currKey] = {}
          temp = temp[currKey]
          i += 1
    lookupTable

  saveQuestion: () ->
    @question.lookup_table = @fixLookupTable()
    @question.prepareSkipLogicDataForSave(@deletedSkipLogicTargets, @deletedSkipLogicConditions)

    @setQuestionResponseOrders()
    @question.addDestroyedQuestionResponses(@destroyedQuestionResponses)
    @question.addDestroyedGridQuestions(@destroyedGridQuestions)
    @setGridQuestionOrders()

    # not sure why this is needed (I think a redactor problem)
    if @question.post_question_text is null or @question.post_question_text is undefined
      @question.post_question_text = ""

    if @question.side_text is null or @question.side_text is undefined
      @question.side_text = ""

    if @question.question_response_type is "grid"
      @_.each @question.grid_questions, (q) => 
        q.question_type = @question.question_type
        q.question_response_type = @gridQrt
        q.question_response_style = if @gridQrt is 'radio' then 'horizontal_radio' else 'normal_yes_no'
        q.remote_data_target = @question.remote_data_target
        q.remote_data_target_type = @question.remote_data_target_type
        q.question_responses_attributes = q.question_responses
        counter = 1
        @_.each q.question_responses_attributes, (r, i) =>
          if !r._destroy and @gridResponses[i]?
            r.question_response_value = @gridResponses[i].question_response_value
            r.question_response_order = counter
            counter += 1
            #r.numeric_value = @gridResponses[counter].numeric_value
            #counter += 1
    if @question.question_response_type is "current_treatment"
      @question.current_treatment_option_ids = @_.pluck(@_.filter(@options[@question.sub_decision_id], (o) -> o.selected), "id")

    if @isNewQuestion
      @question.$save {decision_aid_id: @$stateParams.decisionAidId}, ((q) => @goBack(q)), ((error) => @handleError(error))
    else
      @question.$update {decision_aid_id: @$stateParams.decisionAidId}, ((q) => @goBack(q)), ((error) => @handleError(error))

module.controller 'QuestionEditCtrl', QuestionEditCtrl

