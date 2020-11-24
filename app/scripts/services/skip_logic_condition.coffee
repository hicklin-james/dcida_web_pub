'use strict'

angular.module('dcida20App')
  .factory 'SkipLogicCondition', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->

    SkipLogicCondition = {}

    SkipLogicCondition.buildSkipLogicCondition = (decisionAidId, questionId) ->
      retVal = {}
      retVal.decision_aid_id = decisionAidId
      retVal.logical_operator = "logical_and"
      return retVal

    return SkipLogicCondition
  ]
