'use strict'

angular.module('dcida20App')
  .factory 'OptionProperty', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['information', 'short_label', 'option_id', 'property_id', 'ranking', 'ranking_type', 'button_label']
    actions = Util.resourceActions 'option_property', 'option_properties', attributes

    OptionProperty = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/option_properties/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    OptionProperty.addNewOptionProperties = (currentOptionProperties, option, propertyId) ->
      existingOptionMap = _.indexBy currentOptionProperties, 'option_id'
      newOptionProperties = []
      _.each option.sub_options, (o) =>
        if !existingOptionMap[o.id]
          op = new OptionProperty
          op.option_id = o.id
          op.property_id = parseInt(propertyId)
          op.option_label = o.label
          newOptionProperties.push op
        else
          existingOptionMap[o.id].option_label = o.label

      currentOptionProperties.concat newOptionProperties

    OptionProperty.createOptionPropertiesHash = (optionProperties) ->
      optionPropertiesHash = {}
      _.each optionProperties, (optionProperty) =>
        if !optionPropertiesHash[optionProperty.option_id]?
          optionPropertiesHash[optionProperty.option_id] = {}
        optionPropertiesHash[optionProperty.option_id][optionProperty.property_id] = optionProperty

      optionPropertiesHash

    OptionProperty.updateBulk = (optionProperties, decisionAidId) ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/option_properties/update_bulk", {option_properties: optionProperties})
        .success((data) ->
          d.resolve(data.option_properties)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    OptionProperty.preview = (decisionAidId) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/option_properties/preview")
        .success((data) ->
          d.resolve(data.option_properties)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise


    return OptionProperty
  ]
