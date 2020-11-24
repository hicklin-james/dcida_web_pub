'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdUserExportQuestionSelector', [ '_', (_) ->
  restrict: 'E'
  scope:
    questions: "=saQuestions"
  templateUrl: "views/directives/user_export_question_selector.html"
  
  link: (scope, element, attrs) ->

    scope.$watch "questions", (nv, ov) ->
      scope.allSelected()
      scope.noneSelected()
    , true

    scope.allSelected = () ->
      scope.all = scope.questions and _.every (scope.questions), (q) -> q.checked

    scope.noneSelected = () ->
      scope.none = scope.questions and _.every (scope.questions), (q) -> !q.checked

    scope.selectAll = () ->
      if !scope.all
        _.each scope.questions, (q) ->
          q.checked = true
          scope.all = true
          scope.none = false

    scope.selectNone = () ->
      if !scope.none
        _.each scope.questions, (q) ->
          q.checked = false
          scope.none = true
          scope.all = false
]