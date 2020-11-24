'use strict'

angular.module('dcida20App')
  .factory 'SkipLogicTarget', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->

    SkipLogicTarget = {}

    SkipLogicTarget.buildSkipLogicTarget = (decisionAidId) ->
      retVal = {}
      retVal.decision_aid_id = decisionAidId
      retVal.skip_logic_conditions = []
      retVal.include_query_params = false
      return retVal

    return SkipLogicTarget
  ]
