'use strict'

module = angular.module('dcida20App')

module.filter 'removeHTMLTags', () ->
  (input) ->
    if input then String(input).replace(/<[^>]+>/gm, '') else ''

module.factory 'QuestionControl', ['$q', '_', 'DecisionAidUserResponse', 'Question', '$anchorScroll', '$ngSilentLocation', 'Confirm', 'DecisionAidHome', '$translate', '$timeout', '$uibModal', ($q, _, DecisionAidUserResponse, Question, $anchorScroll, $ngSilentLocation, Confirm, @DecisionAidHome, $translate, $timeout, $uibModal) ->
  class QuestionControl
    constructor: (decisionAid, @decisionAidUser, userResponses, stateParams, @questionType, @currRoute, @scope) ->
      @decisionAidSlug = decisionAid.slug
      @decisionAid = decisionAid
      @stringifiedRanks = ["1<sup>st</sup>", "2<sup>nd</sup>", "3<sup>rd</sup>", "4<sup>th</sup>", "5<sup>th</sup>", "6<sup>th</sup>", "7<sup>th</sup>", "8<sup>th</sup>", "9<sup>th</sup>", "10<sup>th</sup>", "11<sup>th</sup>", "12<sup>th</sup>",
        "13<sup>th</sup>", "14<sup>th</sup>", "15<sup>th</sup>", "16<sup>th</sup>"]
      @currentQuestionPage = decisionAid.question_page

      @responsesHash = _.indexBy(userResponses, 'question_id')

      if @currentQuestionPage

        @questions = @currentQuestionPage.questions
        @indexedQuestions = _.indexBy(@questions, 'id')

        _.each @questions, (q) =>
          if @currentQuestionPage and q.question_responses
            q.indexedResponses = _.indexBy q.question_responses, "id"

          if q.question_response_type is "sum_to_n"
            @scope.$watch "ctrl.qc.responsesHash[#{q.id}].json_response_value", (newVal, oldVal) =>
              q.summedResponseValues = _.reduce(_.values(newVal), ((memo, v) => 
                memo + (if v and !isNaN(v) then parseInt(v) else 0)), 
              0)
            , true

          if q.question_response_type is "radio"
            q.chunked_responses = _.chunk(q.question_responses, 6)

          if q.question_response_type != "grid"
            if !@responsesHash[q.id]
              r = new DecisionAidUserResponse()
              r.question_id = q.id
              r.decision_aid_user_id = @decisionAidUser.id
              r.json_response_value = {}
              r.evaluated = false
              @responsesHash[q.id] = r
              q.nonEditable = false
            else
              q.nonEditable = !q.can_change_response
              if q.question_response_type is "slider" and @responsesHash[q.id].number_response_value?
                @responsesHash[q.id].evaluated = true
            
            if (!@responsesHash[q.id].selected_unit and q.units_array.length > 0) or
                (q.units_array.length > 0 and !_.some(q.units_array, (unit) => unit is @responsesHash[q.id].selected_unit))
              @responsesHash[q.id].selected_unit = q.units_array[0]
            else if @responsesHash[q.id].selected_unit and q.units_array.length is 0
              @responsesHash[q.id].selected_unit = null

          else
            if !@responsesHash[q.id]
              r = new DecisionAidUserResponse()
              r.question_id = q.id
              r.decision_aid_user_id = @decisionAidUser.id
              @responsesHash[q.id] = r
              q.nonEditable = false
            else
              q.nonEditable = !q.can_change_response

            q.hasPostQuestionText = false
            _.each q.grid_questions, (gq) =>
              if !q.hasPostQuestionText and 
                  gq.question_response_type is 'radio' and
                  gq.post_question_text_published
                q.hasPostQuestionText = true

              if !@responsesHash[gq.id]
                r = new DecisionAidUserResponse()
                r.question_id = gq.id
                r.decision_aid_user_id = @decisionAidUser.id
                @responsesHash[gq.id] = r

          if q.question_response_type is "ranking"
            @prepareRankingData(q)

          if q.question_response_type is "sum_to_n"
            @prepareSumToNData(q)

          @setQuestionTableWidths(q)

    getRange: (min, max) ->
      new Array(max-min+1)

    setEvaluated: (response) ->
      response.evaluated = true

    prepareSumToNData: (q) ->
      valid_keys = _.pluck(q.question_responses, 'id')
      @responsesHash[q.id].json_response_value = _.pick(@responsesHash[q.id].json_response_value, valid_keys)
      
      total_allocatable = q.max_number - _.reduce(_.values(@responsesHash[q.id].json_response_value), ((memo, v) => 
        memo + (if v and !isNaN(v) then parseInt(v) else 0)), 
      0)

      q.sourceStack = new Array(total_allocatable)
      _.each q.question_responses, (qr) =>
        qr.destStack = if @responsesHash[q.id].json_response_value[qr.id]
          new Array(parseInt(@responsesHash[q.id].json_response_value[qr.id]))
        else
          new Array(0)

    addToConstantSumStack: (q, qr) ->
      if q.sourceStack.length > 0
        @responsesHash[q.id].json_response_value[qr.id] ||= 0
        @responsesHash[q.id].json_response_value[qr.id] += 1
        qr.destStack.push(null)
        q.sourceStack.pop()

    removeFromConstantSumStack: (q, qr) ->
      if qr.destStack.length > 0
        @responsesHash[q.id].json_response_value[qr.id] ||= 0
        @responsesHash[q.id].json_response_value[qr.id] -= 1
        qr.destStack.pop()
        q.sourceStack.push(null)

    prepareRankingData: (q) ->
      q.orderedRanks = []
      #@unorderedRanks = []
      if @responsesHash[q.id].json_response_value
        _.each q.question_responses, (qr) =>
          if @responsesHash[q.id].json_response_value[qr.id]
            q.orderedRanks.push angular.copy(qr)
            qr.inOrderedRanks = true
      else
        @responsesHash[q.id].json_response_value = {}

      q.orderedRanks = _.sortBy(q.orderedRanks, (qr) => @responsesHash[q.id].json_response_value[qr.id])

    prepareRankingDataForSave: (q) =>
      @responsesHash[q.id].json_response_value = {}

      _.each q.orderedRanks, (qr, i) =>
        @responsesHash[q.id].json_response_value[qr.id] = (i + 1)

    addResponseToOrderedRanks: (q, qr) =>
      if !qr.inOrderedRanks
        qr.inOrderedRanks = true
        q.orderedRanks.push angular.copy(qr)

    clearOrderedRanks: (q) =>
      q.orderedRanks = []
      _.each q.question_responses, (qr) =>
        qr.inOrderedRanks = false

    # onRankedQuestionSort: (qr, from, to, iFrom, iTo) =>
    #   console.log qr

    setNumResponsesForRadio: (q, numResponses) ->
      if numResponses <= 6 and !q.hasPostQuestionText
        responseDifference = 12 - numResponses
        q.responseClass = "col-sm-1"
        q.questionClass = "col-sm-#{responseDifference}"
      else
        q.responseClass = "col-sm-1"
        q.questionClass = "col-sm-4"
        if q.hasPostQuestionText
          q.questionClass = "col-sm-2"
          q.postQuestionClass = "col-sm-#{12-numResponses-2}"

    setQuestionTableWidths: (q) ->
      if q
        if q.question_response_type is "radio" and q.question_response_style is "vertical_radio"
          #numResponses = @currentQuestion.question_responses.length
          #@setNumResponsesForRadio(numResponses)
          q.responseClass = "col-sm-1"
          q.questionClass = "col-sm-11"
        else if q.question_response_type is "grid"
          if q.grid_questions[0]?.question_response_type is "radio"
            numResponses = q.grid_questions[0].question_responses.length
            @setNumResponsesForRadio(q, numResponses)
          else if q.grid_questions[0]?.question_response_type is "yes_no"
            q.responseClass = "col-sm-1"
            q.questionClass = "col-sm-11"

    questionComplete: (q) ->
      if q.isFirst
        q.complete
      else
        if q.question_type is "grid"
          _.every q.grid_questions, (q) => @responsesHash[q.id].id
        else
          @responsesHash[q.id].id

    selectResponse: (question, response) ->
      nonEditable = if question.question_id then @indexedQuestions[question.question_id].nonEditable else question.nonEditable
      if !nonEditable || !@responsesHash[question.id].id
        if @responsesHash[question.id].question_response_id isnt response.id
          # show popup immediately for grid questions
          # if question.question_id and response.include_popup_information
          #   Confirm.questionResponse(
          #     popup_information: response.injected_popup_information_published,
          #     buttonType: "default"
          #   )
          @responsesHash[question.id].question_response_id = response.id
          # @nonEditable = !@currentQuestion.can_change_response
      return null

    selectOption: (question, option) ->
      @responsesHash[question.id].option_id = option.id
      return null

    selectYesNoResponse: (question) ->
      nonEditable = if question.question_id then @indexedQuestions[question.question_id].nonEditable else question.nonEditable
      if !nonEditable || !@responsesHash[question.id].id
        if @responsesHash[question.id].question_response_id is question.question_responses[0].id
          @responsesHash[question.id].question_response_id = question.question_responses[1].id
        else
          if question.question_id
            if question.is_exclusive
              _.each @indexedQuestions[question.question_id].grid_questions, (gq) =>
                if gq.id isnt question.id
                  @responsesHash[gq.id].question_response_id = gq.question_responses[1].id
            else
              _.each @indexedQuestions[question.question_id].grid_questions, (gq) =>
                if gq.is_exclusive
                  @responsesHash[gq.id].question_response_id = gq.question_responses[1].id
          @responsesHash[question.id].question_response_id = question.question_responses[0].id

    scrollToTop: () ->
      $anchorScroll()

    questionClick: (i) ->
      if i.available
        if i.isFirst
          @goToQuestionIntro()
        else
          ind = _.findIndex @questions, (q) => q.id is i.question_id
          @goToQuestionAtIndex(ind)

    prepareSliderForSave: (q) ->
      if !@responsesHash[q.id].evaluated
        console.log "Reset number response value"
        @responsesHash[q.id].number_response_value = null

    nextAction: () ->
      @validationErrors = {}
      if !@currentQuestionPage
        @scope.ctrl.NavBroadcastService.emitLoadingToRoot(true, @scope)
        return "first"
      else
        qps = []

        _.each @questions, (q) =>
          # ranking questions have to be prepared for save
          qp = $q.defer()
          qps.push(qp.promise)

          if q.question_response_type is "ranking"
            @prepareRankingDataForSave(q)

          # if the response has been answered, we can validate the response
          if responseComplete(q, @responsesHash)
            if q.question_response_type is "number"
              r = @validateNumberResponse(q, @responsesHash)
              if !r.valid
                $translate(['OOPS', r.translationKey], r.interpolateVals).then (translations) =>
                  @validationErrors[q.id] = translations[r.translationKey]
                
                qp.reject(null)
              else
                qp.resolve()
            else if q.question_response_type is "sum_to_n"
              if q.summedResponseValues > 0 && q.summedResponseValues isnt q.max_number
                @validationErrors[q.id] = if q.question_response_style is "stacking_sum_to_n"
                  "Points must be fully allocated"
                else
                  "Values must sum to #{q.max_number}."
                qp.reject(null)
              else
                qp.resolve()
            else if q.question_response_type is "grid" and 
                    q.grid_questions.length > 0 and
                    q.grid_questions[0].question_response_type is "yes_no" and
                    q.min_number > 0

              if q.min_number > 0
                yes_count = _.filter(q.grid_questions, (q) =>
                  yes_response = _.find q.question_responses, (qr) => qr.question_response_value is "Yes"
                  yes_response and yes_response.id is @responsesHash[q.id].question_response_id
                ).length

                if yes_count < q.min_number
                  $translate(['OOPS', 'GRID-YES-NO-MIN-SELECTION-SINGULAR', 'GRID-YES-NO-MIN-SELECTION-PLURAL'], {min: q.min_number}).then (translations) =>
                    @validationErrors[q.id] = if q.min_number > 1 then translations['GRID-YES-NO-MIN-SELECTION-PLURAL'] else translations['GRID-YES-NO-MIN-SELECTION-SINGULAR']
                  
                  qp.reject(null)
                else
                  qp.resolve()
              else
                qp.resolve()
            else
              qp.resolve()

          else if q.skippable
            qp.resolve()
          else
            $translate(['OOPS', 'RESPONSE-REQUIRED-DETAILS']).then (translations) =>
              @validationErrors[q.id] = translations['RESPONSE-REQUIRED-DETAILS']
              qp.reject(null)


        deferred = $q.defer()

        promiseOfAllPromises = $q.all(qps)
        promiseOfAllPromises.then (resolvedPromises) =>
          # check for response popups
          responsePopupInfos = @accumulateResponsePopups()
          if responsePopupInfos.length > 0
            @showResponsePopups(responsePopupInfos, deferred)
          else
            # all fields are good, so update them all
            @save(deferred)
        , (error) =>
          deferred.reject(null)
          $timeout () =>
            @scope.ctrl.NavBroadcastService.emitLoadingToRoot(false, @scope)
          , 500
        
        return deferred.promise

    showResponsePopups: (responsePopups, deferred) ->
      @scope.ctrl.NavBroadcastService.emitLoadingToRoot(false, @scope)
      @modalInstance = $uibModal.open(
        templateUrl: "/views/home/decision_aid/response_popups.html"
        controller: "ResponsePopupsCtrl"
        size: 'lg'
        resolve:
          options: () =>
            response_popups: responsePopups
      )

      saveDeferred = () =>
        @scope.ctrl.NavBroadcastService.emitLoadingToRoot(true, @scope)
        @save(deferred)

      @modalInstance.result.then(saveDeferred, saveDeferred)

    accumulateResponsePopups: () ->
      responsePopupInfos = []
      _.each @questions, (q) =>
        if q.question_response_type is "radio" or
           q.question_response_type is "yes_no"

          responseHash = _.indexBy(q.question_responses, "id")

          rObj = responseHash[@responsesHash[q.id].question_response_id]
          if rObj and rObj.include_popup_information
            responsePopupInfos.push({
              popup_info: rObj.injected_popup_information_published,
              question_text: q.question_text_published,
              response: rObj.question_response_value
            })

        if q.question_response_type is "grid"
          _.each q.grid_questions, (gq) =>
            responseHash = _.indexBy(gq.question_responses, "id")

            rObj = responseHash[@responsesHash[gq.id].question_response_id]
            if rObj and rObj.include_popup_information
              responsePopupInfos.push({
                popup_info: rObj.injected_popup_information_published,
                question_text: q.question_text_published,
                grid_question_text: gq.question_text_published,
                response: rObj.question_response_value
              })

      return responsePopupInfos

    save: (pp) ->
      @saveResponse().then (data) =>
        if data
          if data.decision_aid_user_responses and
             data.decision_aid_user_responses.length > 0 and
             data.decision_aid_user_responses[0].url_to_skip_to

            pp.resolve({skip_to: data.decision_aid_user_responses[0].skip_to, url_to_skip_to: data.decision_aid_user_responses[0].url_to_skip_to}) 
          if data.url_to_skip_to
            pp.resolve({url_to_skip_to: data.url_to_skip_to, url_to_skip_to: data.url_to_skip_to})
          else if data.$metadata and data.$metadata.next_question_page
            next_question_page_id = data.$metadata.next_question_page.id
            pp.resolve({next_question_page: "next", next_question_page_id: next_question_page_id})
          else
            pp.resolve({next_question_page: "finished"})
        else
          pp.resolve({next_question_page: "finished"})

      ,(data) =>
        @scope.ctrl.NavBroadcastService.emitLoadingToRoot(false, @scope)
        if data.errors
          @scope.ctrl.errors = data.errors
        pp.reject(data.errors)

    validateNumberResponse: (q, responses) ->
      if q.max_number? and responses[q.id].number_response_value > q.max_number
        return {
          valid: false,
          translationKey: 'NUMBER-RESPONSE-TOO-LARGE',
          interpolateVals: {max_number: q.max_number}
        }
      else if q.min_number? and responses[q.id].number_response_value < q.min_number
        return {
          valid: false,
          translationKey: "NUMBER-RESPONSE-TOO-SMALL",
          interpolateVals: {min_number: q.min_number}
        }
      else if q.max_chars? and q.min_chars? and q.max_chars is q.min_chars and responses[q.id].number_response_value.toString().length isnt q.max_chars
        return {
          valid: false,
          translationKey: "NUMBER-RESPONSE-DIGITS-NOT-EQUAL",
          interpolateVals: {max_chars: q.max_chars}
        }
      else if q.max_chars? and responses[q.id].number_response_value.toString().length > q.max_chars
        return {
          valid: false,
          translationKey: "NUMBER-RESPONSE-DIGITS-TOO-MANY",
          interpolateVals: {max_chars: q.max_chars}
        }
      else if q.min_chars? and responses[q.id].number_response_value.toString().length < q.min_chars
        return {
          valid: false,
          translationKey: "NUMBER-RESPONSE-DIGITS-TOO-FEW",
          interpolateVals: {min_chars: q.min_chars}
        }
      else
        return {
          valid: true
        }
    
    prevAction: () ->
      if @currentQuestionPage.question_page_order is 1
        return "gobacksection"
      else 
        return "gobackwithinsection"

    percentageCompleted: () ->
      answeredQuestions = _.filter @questions, (q) =>
          responseComplete(q, @responsesHash) and @responsesHash[q.id].id?
      r = answeredQuestions.length / @questions.length #@decisionAid["#{@questionType}_questions_count"]
      data = 
        percentageCompleted: r
      @scope.$emit 'dcida.percentageCompletedUpdate', data

    goToQuestionIntro: () ->
      @currentQuestion = null
      @currentQuestionIndex = null
      $ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/#{@currRoute}")

    goToQuestionAtIndex: (index) ->
      @currentQuestion = @questions[index]
      @setQuestionTableWidths()
      @currentQuestionIndex = index
      @scrollToTop()
      $ngSilentLocation.silent("/decision_aid/#{@decisionAidSlug}/#{@currRoute}?question_id=#{@currentQuestion.id}")

    saveMultipleResponses: (responses) ->
      d = $q.defer()
      DecisionAidUserResponse.createAndUpdateBulk(responses, @decisionAidUser.id, @questionType, @currentQuestionPage.id).then (responses) =>
        _.each responses, (r) =>
          @responsesHash[r.question_id] = new DecisionAidUserResponse(r)
        d.resolve(responses)
      , (error) =>
        console.error "Something bad happened"
        d.reject()
      d.promise

    saveOrUpdateResponse: (response) ->
      d = $q.defer()
      if response.id
        response.$update {decision_aid_user_id: @decisionAidUser.id}, (r) =>
          @responsesHash[@currentQuestion.id] = r
          d.resolve(r)
      else
        response.$save {decision_aid_user_id: @decisionAidUser.id}, (r) =>
          @responsesHash[@currentQuestion.id] = r
          d.resolve(r)
      d.promise

    saveResponse: () ->
      d = $q.defer()
      responses = []
      _.each @questions, (q) =>
        responses.push @responsesHash[q.id]
        if q.question_response_type is "grid"
          _.each q.grid_questions, (gq) =>
            responses.push @responsesHash[gq.id]

      @saveMultipleResponses(responses).then (da) =>
        d.resolve(da)
      , (error) =>
        d.reject()
      d.promise

    # private methods

    responseComplete = (q, responsesHash) ->
      r = responsesHash[q.id]
      (q.question_response_type is "text" and responsesHash[q.id].response_value) or
      (q.question_response_type is "grid" and 
        _.every q.grid_questions, (q) => responsesHash[q.id].question_response_id?
      ) or
      (q.question_response_type is "number" and r.number_response_value? and (q.units_array.length is 0 or r.selected_unit?)) or
      (q.question_response_type is "radio" and r.question_response_id?) or
      (q.question_response_type is "current_treatment" and r.option_id?) or
      (q.question_response_type is "yes_no" and r.question_response_id?) or
      (q.question_response_type is "heading") or
      (q.question_response_type is "sum_to_n" and !_.isEmpty(r.json_response_value) and q.summedResponseValues > 0) or 
      (q.question_response_type is "slider" and r.evaluated and r.number_response_value?) or
      (q.question_response_type is "ranking" and 
        _.every q.question_responses, (qr) => r.json_response_value[qr.id]
      )

]
