'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdEquationEditor', ['$document', ($document) ->
  scope:
    ngModel: "="
    questionType: "@saQuestionType"
    decisionAidId: "@saDecisionAidId"
  templateUrl: 'views/directives/equation_editor.html'
  controller: EquationEditorCtrl
]

class EquationEditorCtrl

  @$inject: ['$scope', '_', '$uibModal']
  constructor: (@$scope, @_, @$uibModal) ->
    @$scope.ctrl = @
    @tokenizedModel = if @$scope.ngModel then @$scope.ngModel.split(" ") else []

    # deep watch tokenizedModel
    @$scope.$watch 'ctrl.tokenizedModel', (nv, ov) =>
      if nv isnt ov
        @$scope.ngModel = nv.join(" ")
    , true

  addOperator: (o) ->
    @tokenizedModel.push o

  openQuestionSelection: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/question_picker.html"
      controller: "QuestionPickerCtrl"
      size: 'lg'
      backdrop: 'static'
      resolve: 
        options: () =>
          questionType: @$scope.questionType
          decisionAidId: @$scope.decisionAidId
          flatten: false
          includeResponses: true
          questionResponseType: 'radio,number,yes_no,json,lookup_table,grid,text,slider'
          descriptionText: "Select a question from the list of questions."
    )

    modalInstance.result.then (question) =>
      str = ""
      if question.additional_meta
        str = "[question_#{question.id}_#{question.additional_meta}]"
      else
        str = "[question_#{question.id}]"
      @tokenizedModel.push str

  openNumberPicker: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/shared/number_picker.html"
      controller: "NumberPickerCtrl"
      size: 'sm'
      backdrop: 'static'
    )

    modalInstance.result.then (number) =>
      @tokenizedModel.push number

  removeToken: (index) ->
    @tokenizedModel.splice(index,1)