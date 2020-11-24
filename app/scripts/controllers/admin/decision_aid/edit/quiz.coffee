'use strict'

module = angular.module('dcida20App')

class DecisionAidEditQuizCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'Sortable', 'DecisionAid', 'Question', 'Confirm', 'AdminTabHelper', '_', '$uibModal', 'ErrorHandler', 'QuestionPage', '$q']
  constructor: (@$scope, @$state, @$stateParams, @Sortable, @DecisionAid, @Question, @Confirm, @AdminTabHelper, @_, @$uibModal, @ErrorHandler, @QuestionPage, @$q) ->
    if @$scope.ctrl? && @$scope.ctrl.decisionAid?
      @decisionAid = @$scope.ctrl.decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'decisionAidChanged', (event, decisionAid) =>
      @decisionAid = decisionAid
      @decisionAidEdit = angular.copy @decisionAid

    @$scope.$on 'tabChangeRequested', () =>
      @AdminTabHelper.confirmNavigation(@$scope, @decisionAidEdit)

    @$scope.ctrl = @
    @loading = true

    questions_p = @Question.query({decision_aid_id: @$stateParams.decisionAidId, question_type: "quiz", include_hidden: true}).$promise
    question_pages_p = @QuestionPage.query({decision_aid_id: @$stateParams.decisionAidId, section: "quiz", include_questions: true}).$promise

    $q.all([questions_p, question_pages_p]).then (resolvedPromises) =>
      @hiddenQuestions = resolvedPromises[0]  #@_.filter(questions, (q) -> q.hidden)

      @questionPages = resolvedPromises[1]

      @_.each @questionPages, (qp) =>
        qp.page_questions = @_.map qp.page_questions, (q) => new @Question(q)
        @buildDeletedSkipLogicConditions(qp)
        @buildDeletedSkipLogicTargets(qp)
        
      @loading = false

  addNewQuestionPage: () -> 
    qp = new @QuestionPage
    qp.decision_aid_id = @$stateParams.decisionAidId
    qp.section = "quiz"
    qp.$save {decision_aid_id: @$stateParams.decisionAidId}, (qp) =>
      @questionPages.push qp
    , (error) =>
      console.log "An error occured creating the question page"
      console.log error

  onSort: (question, partFrom, partTo, indexFrom, indexTo) =>
    if question
      questionPage = @_.find @questionPages, (qp) => qp.page_questions is partTo
      if partFrom isnt partTo
        if questionPage
          question.question_order = indexTo + 1
          question.question_page_id = questionPage.id
          @moveQuestionToPage(question, questionPage) if questionPage
      else if partFrom is partTo and 
         question.question_order isnt indexTo + 1

        question.question_order = indexTo + 1
        @reorderQuestion(question, questionPage) if questionPage

  buildDeletedSkipLogicConditions: (qp) ->
    qp.deletedSkipLogicConditions = {}
    @_.each qp.skip_logic_targets, (slt) =>
      qp.deletedSkipLogicConditions[slt.id] = []

  buildDeletedSkipLogicTargets: (qp) ->
    qp.deletedSkipLogicTargets = []

  openSkipLogicEditor: (qp) ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/skip_logic_editor.html"
      controller: "SkipLogicEditorCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAidId: @$stateParams.decisionAidId
          questionPage: qp
          deletedSkipLogicConditions: qp.deletedSkipLogicConditions
          deletedSkipLogicTargets: qp.deletedSkipLogicTargets
      )

    modalInstance.result.then (nqp) =>
      @buildDeletedSkipLogicTargets(nqp)
      @buildDeletedSkipLogicConditions(nqp)
      ind = _.findIndex @questionPages, (qpp) => qpp.id is qp.id
      if ind >= 0
        @questionPages[ind] = nqp

  reorderQuestion: (q, page) ->
    if q.hidden
      @Sortable.reorderItem(q, @hiddenQuestions, "question_order")
    else
      @Sortable.reorderItem(q, page.page_questions, "question_order")

  moveQuestionToPage: (question, page) ->
    question.moveQuestionToPage().then (updatedQuestion) =>
      #console.log "Successfully moved!"
      question = new @Question(updatedQuestion)
    , (error) =>
      console.log "An error occured while moving question"
      console.log error

  moveQuestionPageDown: (page) ->
    page.question_page_order = page.question_page_order + 1
    #console.log page
    @Sortable.reorderItem(page, @questionPages, "question_page_order")
    @Sortable.swap(@questionPages, page.question_page_order - 2, page.question_page_order - 1)

  moveQuestionPageUp: (page) ->
    page.question_page_order = page.question_page_order - 1
    #console.log page
    @Sortable.reorderItem(page, @questionPages, "question_page_order")
    @Sortable.swap(@questionPages, page.question_page_order - 1, page.question_page_order)

  deleteQuestionPage: (page) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this question page? All questions within the page will also be deleted.'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      page.$delete {decision_aid_id: @$stateParams.decisionAidId}, () =>
        @Sortable.finishItemDeletion page, @questionPages, "question_page_order"

  deleteQuestion: (question, page) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this question?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      isHidden = question.hidden
      question.$delete {decision_aid_id: @$stateParams.decisionAidId}, (() => 
        if isHidden
          @Sortable.finishItemDeletion question, @hiddenQuestions, "question_order"
        else
          @Sortable.finishItemDeletion question, page.page_questions, "question_order"
     ),((error) => 
        alert("Question deletion failed")
      )

  saveAndPreview: () ->
    if @$scope.decisionAidEditForm.$dirty
      @save().then () =>
        @preview(@decisionAid)
    else
      @preview(@decisionAid)

  cloneQuestion: (question) ->
    question.clone().then (cloned_question) =>
      @Confirm.alert(
        message: "Success!"
        messageSub: "The question was successfully cloned"
        buttonType: "default"
        headerClass: "text-success"
      )

  preview: (da) ->
    @$uibModal.open(
      templateUrl: "/views/admin/decision_aid/preview/quiz.html"
      controller: "QuizPreviewCtrl"
      size: 'lg'
      resolve:
        options: () =>
          decisionAid: @decisionAid
    )

  @moveQuestionToPage

  handleError: (error) ->
    @errors = @ErrorHandler.handleError(error)

  save: () ->
    @AdminTabHelper.saveDecisionAid(@$scope, @decisionAidEdit).then((() =>

    ), ((error) =>
      @errors = @ErrorHandler.handleError(error)
    ))


module.controller 'DecisionAidEditQuizCtrl', DecisionAidEditQuizCtrl

