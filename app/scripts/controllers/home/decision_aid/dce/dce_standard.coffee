angular.module('dcida20App')
  .factory 'DceStandardCtrl', ['$q', '$timeout', '_', 'Util', ($q, $timeout, _, Util) ->
    class DceStandardCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @properties, @dceQuestionSetResponses, @userSetResponse) ->
        @tasks = []

        @tasks.push(@userSetResponse.dce_question_set_response_id?)

        if @decisionAid.include_dce_confirmation_question
          @tasks.push(@userSetResponse.option_confirmed?)

      selectQsr: (qsr) ->
        @userSetResponse.dce_question_set_response_id = qsr.id
        @tasks[0] = true
        return true

      setOptionConfirmed: (val) ->
        if @tasks[0]
          @userSetResponse.option_confirmed = val
          return true
        return false

      readyForSubmit: () ->
        if _.every(@tasks, (bool) => bool)
          return "readyToSave"

        if (@userSetResponse.dce_question_set_response_id? and !@decisionAid.include_dce_confirmation_question)
          return "readyToSave"

        if @userSetResponse.dce_question_set_response_id? and @decisionAid.include_dce_confirmation_question and @userSetResponse.option_confirmed?
           return "readyToSave"

        return "invalid"

      shouldAutoSubmit: () ->
        !@decisionAid.include_dce_confirmation_question

      submit: () ->
        return @readyForSubmit()

      reset: () ->
        @tasks = _.map @tasks, (bool) -> false
        @userSetResponse.dce_question_set_response_id = null
        @userSetResponse.fallback_question_set_id = null
        @userSetResponse.option_confirmed = null
  ]