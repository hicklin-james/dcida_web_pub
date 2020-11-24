'use strict'

angular.module('dcida20App')
  .factory 'SummaryPanel', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['panel_type', 'option_lookup_json', 'panel_information', 'question_ids', 'lookup_headers_json', 'summary_table_header_json', 'injectable_decision_summary_string', 'summary_page_id']
    actions = Util.resourceActions 'summary_panel', 'summary_panels', attributes

    SummaryPanel = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/summary_panels/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    SummaryPanel.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/summary_panels/#{@id}/update_order", {summary_panel: @})
        .success((data) ->
          d.resolve(data.summary_panel)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    return SummaryPanel
  ]
