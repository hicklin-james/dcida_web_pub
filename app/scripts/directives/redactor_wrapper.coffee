'use strict'

app = angular.module('dcida20App')

app.directive 'sdRedactorWrapper', [ '_', 'Auth', 'RedactorSettings', '$timeout', (_, Auth, RedactorSettings, $timeout) ->
  scope:
    decisionAidId: '@saDecisionAidId'
    questionTypes: "@saQuestionTypes"
  restrict: "E"
  transclude: true
  template:
    '<div ng-if="userIdSet" ng-transclude>
    </div>'
  link: (scope, element, attrs) ->
    includeQuestion = 'saIncludeQuestionSelector' of attrs
    questionTypes = if scope.questionTypes then scope.questionTypes else null

    questionParams =
      includeQuestion: includeQuestion
      questionTypes: questionTypes

    p = null

    userSet = () ->
      id = Auth.currentUserId()
      if id? and !scope.userIdSet and scope.decisionAidId
        RedactorSettings.setUserSpecificRedactorOptions(id, questionParams, scope.decisionAidId)
        scope.userIdSet = true
      scope.userIdSet

    userSetLoop = () ->
      p = $timeout () =>
        if !userSet()
          userSetLoop()
        else
          $timeout.cancel(p)
      , 50

    userSetLoop()
    
]
