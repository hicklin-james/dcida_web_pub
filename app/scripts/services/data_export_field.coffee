'use strict'

angular.module('dcida20App')
  .factory 'DataExportField', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = [ 'exporter_id', 'exporter_type', 'data_target_type', 'redcap_field_name', 'redcap_response_mapping', 'data_export_field_order', 'data_accessor']
    actions = Util.resourceActions 'data_export_field', 'data_export_fields', attributes

    DataExportField = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/data_export_fields/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    DataExportField.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/data_export_fields/#{@id}/update_order", {data_export_field: @})
        .success((data) ->
          d.resolve(data.data_export_field)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    DataExportField.prototype.testRedcapQuestion = (decision_aid_id, redcap_variable) ->
      d = $q.defer()
      params = 
        redcap_question_variable: redcap_variable
      $http.get "#{API_ENDPOINT}/decision_aids/#{decision_aid_id}/data_export_fields/test_redcap_question", params: params
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DataExportField
  ]
