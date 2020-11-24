angular.module('dcida20App')
  .factory 'DceOptOutCtrl', ['$q', '$timeout', '_', 'Util', ($q, $timeout, _, Util) ->
    class DceOptOutCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @properties, @dceQuestionSetResponses, @userSetResponse) ->
        @tasks = [false, false]

        if @userSetResponse.dce_question_set_response_id?
          @tasks[0] = true
        
        if @tasks[0] and @userSetResponse.fallback_question_set_id
          @tasks[1] = true

      selectQsr: (qsr) ->
        if !@tasks[0]
          if qsr.id isnt -1
            @userSetResponse.dce_question_set_response_id = qsr.id
            return true
          return false
        else
          validSelection = null
          if @decisionAid.compare_opt_out_to_last_selected
            validSelection = _.find([-1, @userSetResponse.dce_question_set_response_id], (sqsr) => sqsr is qsr.id)
          else
            validSelection = qsr.id isnt @userSetResponse.dce_question_set_response_id

          if validSelection
            @userSetResponse.fallback_question_set_id = qsr.id
            return true
          return false

      readyForSubmit: () ->
        if _.every(@tasks, (bool) => bool)
          return "readyToSave"

        if !@tasks[0] and @userSetResponse.dce_question_set_response_id?
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