'use strict'

angular.module('dcida20App')
  .factory 'Property', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = [ 'title', 'selection_about', 'short_label', 'long_about', 'is_property_weighable', 
      'are_option_properties_weighable', 'property_levels_attributes', 'property_group_title', 'backend_identifier'
    ]
    actions = Util.resourceActions 'property', 'properties', attributes

    Property = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/properties/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    Property.prototype.preparePropertyLevelsForUpload = (deletedPropertyLevels) ->
      @property_levels_attributes = @property_levels.concat deletedPropertyLevels

    Property.preview = (decisionAidId) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/properties/preview")
        .success((data) ->
          d.resolve(data.properties)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    Property.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/properties/#{@id}/update_order", {property: @})
        .success((data) ->
          d.resolve(data.property)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    Property.prototype.clone = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/properties/#{@id}/clone")
        .success((data) ->
          d.resolve(data.property)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return Property
  ]
