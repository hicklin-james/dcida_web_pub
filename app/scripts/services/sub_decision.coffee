'use strict'

angular.module('dcida20App')
  .factory 'SubDecision', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['required_option_ids', 'options_information', 'my_choice_information']
    actions = Util.resourceActions 'sub_decision', 'sub_decisions', attributes

    SubDecision = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/sub_decisions/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    return SubDecision
  ]
