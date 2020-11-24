'use strict'

angular.module('dcida20App')
  .factory 'SummaryPage', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['include_admin_summary_email', 'is_primary', 'summary_email_addresses', 'backend_identifier']
    actions = Util.resourceActions 'summary_page', 'summary_pages', attributes

    SummaryPage = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/summary_pages/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    SummaryPage.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/summary_pages/#{@id}/update_order", {summary_page: @})
        .success((data) ->
          d.resolve(data.summary_page)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    return SummaryPage
  ]
