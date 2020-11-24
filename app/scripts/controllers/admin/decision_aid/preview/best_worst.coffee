'use strict'

module = angular.module('dcida20App')

class BestWorstPreviewCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'options', '$uibModalInstance', '$q', 'BwQuestionSetResponse', '_']
  constructor: (@$scope, @$state, @$location, @Auth, options, @$uibModalInstance, @$q, @BwQuestionSetResponse, @_) ->
    @$scope.ctrl = @
    @loading = true
    
    fullDa = options.decisionAid

    @$q.all([fullDa.preview(), @BwQuestionSetResponse.preview(fullDa.id)]).then (prs) =>

      @decisionAid = prs[0]
      @bwQuestionSetResponses = @_.indexBy(prs[1], "question_set")

      @currentQuestionSet = null

      @loading = false

  next: () ->
    if !@currentQuestionSet
      @currentQuestionSet = 1
    else if @currentQuestionSet and @bwQuestionSetResponses[@currentQuestionSet + 1]
      @currentQuestionSet += 1

  prev: () ->
    if @currentQuestionSet
      if @currentQuestionSet is 1
        @currentQuestionSet = null
      else
        @currentQuestionSet -= 1
    
  close: () ->
    @$uibModalInstance.close()

module.controller 'BestWorstPreviewCtrl', BestWorstPreviewCtrl