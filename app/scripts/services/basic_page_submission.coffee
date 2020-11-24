'use strict'

angular.module('dcida20App')
  .factory 'BasicPageSubmission', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['decision_aid_user_id', 'option_id', 'sub_decision_id', 'intro_page_id']
    actions = Util.resourceActions 'basic_page_submission', 'basic_page_submissions', attributes

    BasicPageSubmission = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/basic_page_submissions/:id", { decision_aid_user_id: '@decision_aid_user_id', id: '@id' }, actions

    return BasicPageSubmission
  ]
