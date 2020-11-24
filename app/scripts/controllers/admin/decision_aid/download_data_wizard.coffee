'use strict'

module = angular.module('dcida20App')

class DownloadDataWizard
  @$inject: ['$scope', 'Auth', '$timeout', 'Util', 'DecisionAid', 'Confirm', 'options', '$uibModalInstance', 'Question', '_', 'DownloadManager']
  constructor: (@$scope, @Auth, @$timeout, @Util, @DecisionAid, @Confirm, @options, @$uibModalInstance, @Question, @_, @DownloadManager) ->
    @$scope.ctrl = @
    @loading = true

    @decisionAid = @options.decisionAid

    @selections = {}

    @sections = [
      title: "Global Attributes"
      val: "global_attrs"
     ,
      title: "Demographic Questions"
      val: "demo_questions"
     ,
      title: "Demographic Data Sources"
      val: "demo_data_sources"
     ,
      title: "Quiz Questions"
      val: "quiz_questions"
     ,
      title: "Quiz Data Sources"
      val: "quiz_data_sources"
     ,
      title: "Summary"
      val: "summary"
    ]

    @selections = [
      label: "Created at"
      key: "created_at"
      val: true
      information: "The timestamp of the user's first access to the decision aid"
     ,
      label: "Database ID"
      key: "id"
      val: true
      information: "The auto-generated unique ID of the user"
     ,
      label: "PID"
      key: "pid"
      val: true
      information: "The optional passed-in PID of the user"
     ,
      label: "Platform"
      key: "platform"
      val: true
      information: "The platform that the user is using (e.g. Macintosh, Windows, Android)"
     ,
      label: "Block number"
      key: "block_number"
      val: true
      information: "The block number (useful for DCEs)"
     ,
      label: "Time to complete (estimated)"
      key: "time_to_complete",
      val: true,
      information: "The estimated time that it took to complete the tool"
     ,
      label: "Property weights"
      key: "prop_weights"
      val: true
      information: "The weight of each individual property"
     ,
      label: "Option property weights"
      key: "op_weights"
      val: true
      information: "The weight of each individual option property"
     ,
      label: "Selected Option"
      key: "selected_option"
      val: true
      information: "The selected option for each sub decisions"
     ,
      label: "Match percentages"
      key: "match_percentages"
      val: true
      information: "The percentage match for each option in each sub decision"
    ]

    if @decisionAid.decision_aid_type is "dce" or @decisionAid.decision_aid_type is "dce_no_results"
      @selections.push {
        label: "DCE selections"
        key: "dce_selections"
        val: true,
        information: "The user selections in the DCE"
      }

    if @decisionAid.decision_aid_type is "best_worst" or @decisionAid.decision_aid_type is "best_worst_no_results" or @decisionAid.decision_aid_type is "best_worst_with_prefs_after_choice"
       @selections.push {
        label: "Best/worst selections"
        key: "best_worst_selections"
        val: true
        information: "The user selections in the best/worst exercise"
       }

    if @decisionAid.decision_aid_type is "decide"
      @selections.push {
        label: "Other values entered"
        key: "other_values"
        val: true
        information: "The user-defined values entered on the values clarification"
      }

    @currSection = @sections[0]

    @Question.query {decision_aid_id: @decisionAid.id, question_type: "demographic,quiz", include_responses: true}, (questions) =>
      @demographicQuestions = @_.filter(questions, (q) -> !q.hidden and !q.question_id and q.question_type is "demographic")
      @hiddenDemographicQuestions =  @_.filter(questions, (q) -> q.hidden and q.question_type is "demographic")

      @quizQuestions = @_.filter(questions, (q) -> !q.hidden and !q.question_id and q.question_type is "quiz")
      @hiddenQuizQuestions =  @_.filter(questions, (q) -> q.hidden and q.question_type is "quiz")

      @loading = false

  selectAllVisibleQuestions: () ->
    if !@allVisibleQuestionsSet()
      @_.each @demographicQuestions, (q) ->
        q.checked = true

      @_.each @quizQuestions, (q) ->
        q.checked = true
    else
      @_.each @demographicQuestions, (q) ->
        q.checked = false

      @_.each @quizQuestions, (q) ->
        q.checked = false      

  selectAllHiddenQuestions: () ->
    if !@allHiddenQuestionsSet()
      @_.each @hiddenDemographicQuestions, (q) ->
        q.checked = true

      @_.each @hiddenQuizQuestions, (q) ->
        q.checked = true
    else
      @_.each @hiddenDemographicQuestions, (q) ->
        q.checked = false

      @_.each @hiddenQuizQuestions, (q) ->
        q.checked = false      

  allVisibleQuestionsSet: () ->
    demoQuestionsSet = @_.every @demographicQuestions, (q) -> q.checked
    quizQuestionsSet = @_.every @quizQuestions, (q) -> q.checked

    demoQuestionsSet && quizQuestionsSet && ((@demographicQuestions && @demographicQuestions.length > 0) or (@quizQuestions && @quizQuestions.length > 0))

  allHiddenQuestionsSet: () ->
    demoDataSourcesSet = @_.every @hiddenDemographicQuestions, (q) -> q.checked
    demoQuizQuestionsSet = @_.every @hiddenQuizQuestions, (q) -> q.checked

    demoDataSourcesSet && demoQuizQuestionsSet && ((@hiddenDemographicQuestions && @hiddenDemographicQuestions.length > 0) or (@hiddenQuizQuestions && @hiddenQuizQuestions.length > 0))

  nextSection: () ->
    currSectionIndex = @_.findIndex @sections, (s) => s is @currSection
    @currSection = @sections[currSectionIndex+1] if currSectionIndex < @sections.length-1

  goToSection: (section) ->
    @currSection = section

  prevSection: () ->
    currSectionIndex = @_.findIndex @sections, (s) => s is @currSection
    @currSection = @sections[currSectionIndex-1] if currSectionIndex > 0

  export: () ->
    finalSelections = @_.map(@_.filter(@selections, (selec) -> selec.val), (selec) -> selec.key)
    finalDemographicQuestions = @_.map(@_.filter(@demographicQuestions, (q) -> q.checked), (q) -> q.id)
    finalHiddenDemographicQuestions = @_.map(@_.filter(@hiddenDemographicQuestions, (q) -> q.checked), (q) -> q.id)
    finalQuizQuestions = @_.map(@_.filter(@quizQuestions, (q) -> q.checked), (q) -> q.id)
    finalHiddenQuizQuestions = @_.map(@_.filter(@hiddenQuizQuestions, (q) -> q.checked), (q) -> q.id)

    exportData = {
      selections: finalSelections
      demographicQuestions: finalDemographicQuestions
      hiddenDemographicQuestions: finalHiddenDemographicQuestions
      quizQuestions: finalQuizQuestions
      hiddenQuizQuestions: finalHiddenQuizQuestions
    }

    @DownloadManager.performDownloadRequest(@decisionAid, 'downloadUserData', [{export_data: exportData}], '_userdata_download', @decisionAid).then (d) =>
      

  close: () ->
    @$uibModalInstance.dismiss('cancel')


module.controller 'DownloadDataWizard', DownloadDataWizard

