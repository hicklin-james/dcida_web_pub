'use strict'

module = angular.module('dcida20App')

class DcePreviewController
  @$inject: ['$scope', '$state', '$location', 'Auth', 'options', '$uibModalInstance', '$q', 'DceQuestionSetResponse', 'Property', '_']
  constructor: (@$scope, @$state, @$location, @Auth, options, @$uibModalInstance, @$q, @DceQuestionSetResponse, @Property, @_) ->
    @$scope.ctrl = @
    @loading = true
    
    fullDa = options.decisionAid

    @letters = ["A", "B", "C", "D", "E", "F"]

    @$q.all([fullDa.preview(), @DceQuestionSetResponse.preview(fullDa.id), @Property.preview(fullDa.id)]).then (promises) =>
      @decisionAid = promises[0]
      @allDceQuestionSetResponses = promises[1]
      @dceQuestionSetResponses =  @_.groupBy(@_.sortBy(@_.groupBy(promises[1], "block_number")[1], "response_value"), "question_set")
      #@firstBlock = @_.groupBy(@dceQuestionSetResponses, "block_number"))
      @properties = promises[2]
      @setupProperties()

      @currentQuestionSet = null

      #console.log @optOutOption
      #if @optOutOption

      #  @dceQuestionSetResponses.splice(-1,1)
      #  @dceQuestionSetResponses = @dceQuestionSetResponses.reverse()

      @loading = false

    # @$q.all([fullDa.preview(), @IntroPage.preview(fullDa.id)]).then (promises) =>
    #   @decisionAid = promises[0]
    #   @introPages = promises[1]
    #   @currentIntroPage = @introPages[0]
    #   @loading = false

  setupProperties: () ->
    @_.each @properties, (p) =>
      plevels = p.property_levels
      p.property_level_hash = @_.indexBy plevels, 'level_id'

  setOptOutOption: () ->
    if @currentQuestionSet
      @optOutOption = (if @dceQuestionSetResponses[@currentQuestionSet] then @_.find(@dceQuestionSetResponses[@currentQuestionSet], (dceqr) => dceqr.is_opt_out) else false)
      if @optOutOption
        @theseDcrs = @dceQuestionSetResponses[@currentQuestionSet].reverse()
        @theseDcrs = @theseDcrs.slice(0,@dceQuestionSetResponses[@currentQuestionSet].length - 1)
        #console.log @theseDcrs
        @theseDcrs = @theseDcrs.reverse()
        #@$scope.$apply()
        #console.log @theseDcrs

  next: () ->
    if !@currentQuestionSet and @dceQuestionSetResponses[1]
      @currentQuestionSet = 1
    else if @currentQuestionSet and @dceQuestionSetResponses[@currentQuestionSet + 1]
      @currentQuestionSet += 1

    @setOptOutOption()
    # if @currentIntroPage.intro_page_order < @introPages.length
    #   @currentIntroPage = @introPages[@currentIntroPage.intro_page_order]

  prev: () ->
    if @currentQuestionSet
      if @currentQuestionSet is 1
        @currentQuestionSet = null
      else
        @currentQuestionSet -= 1

    @setOptOutOption()
    # if @currentIntroPage.intro_page_order > 1
    #   @currentIntroPage = @introPages[@currentIntroPage.intro_page_order-2]

  close: () ->
    @$uibModalInstance.close()

module.controller 'DcePreviewController', DcePreviewController
