angular.module('dcida20App')
  .factory 'DceConditionalCtrl', ['$q', '$timeout', '_', 'Util', ($q, $timeout, _, Util) ->
    class DceConditionalCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @properties, @dceQuestionSetResponses, @userSetResponse) ->
        @tasks = [false, false]

        if @userSetResponse.dce_question_set_response_id is -1
          @tasks[0] = true
        
        if @tasks[0] and @userSetResponse.fallback_question_set_id
          @tasks[1] = true

      selectQsr: (qsr) ->
        if !@tasks[0]
          @userSetResponse.dce_question_set_response_id = qsr.id
        else
          if qsr.id isnt -1
            @userSetResponse.fallback_question_set_id = qsr.id

      readyForSubmit: () ->
        if _.every(@tasks, (bool) => bool)
          return "readyToSave"

        if !@tasks[0] and @userSetResponse.dce_question_set_response_id?
          if @userSetResponse.dce_question_set_response_id isnt -1
            return "readyToSave"
          @tasks[0] = true
          return "firstDecisionCompleted"
        
        if !@tasks[1] and @userSetResponse.fallback_question_set_id?
          return "readyToSave"

        return "invalid"

      shouldAutoSubmit: () ->
        true

      submit: () ->
        return @readyForSubmit()

      reset: () ->
        @tasks = _.map @tasks, (bool) -> false
        @userSetResponse.dce_question_set_response_id = null
        @userSetResponse.fallback_question_set_id = null
  ]