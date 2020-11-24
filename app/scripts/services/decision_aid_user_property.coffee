'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUserProperty', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['id', 'property_id', 'decision_aid_user_id', 'weight', 'order', 'color', 'traditional_value', 'traditional_option_id']
    actions = Util.resourceActions 'decision_aid_user_property', 'decision_aid_user_properties', attributes

    DecisionAidUserProperty = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/decision_aid_user_properties/:id", { id: '@id', decision_aid_user_id: '@user_id' }, actions

    DecisionAidUserProperty.prototype.initialize = (property, decision_aid_user, properties_length) ->
      @property_id = property.id
      @decision_aid_user_id = decision_aid_user.id
      @weight = 50
      @property_title = (if property.short_label then property.short_label else property.title)
      @order = properties_length + 1

    DecisionAidUserProperty.sanitizeForUpdate = (properties) ->
      props = angular.copy properties
      _.each props, (property) =>
        _.each property, (value, k) =>
          if _.indexOf(attributes, k) == -1
            delete property[k]
      props      

    DecisionAidUserProperty.updateSelections = (properties, decision_aid_user_id) ->
      d = $q.defer()
      props = @sanitizeForUpdate(properties)
      params = 
        properties: props
      $http.post("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user_id}/decision_aid_user_properties/update_selections", decision_aid_user_properties: params)
        .success((data) ->
          d.resolve(data.decision_aid_user_properties)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAidUserProperty.createMissingProperties = (daups, props, decision_aid_user) ->
      difference = _.filter props, (p) => !_.find daups, (daup) => daup.property_id is p.id

      newProps = []
      _.each difference, (p) =>
        prop = new DecisionAidUserProperty()
        prop.color = "#ffffff"
        prop.initialize(p, decision_aid_user, daups.length + newProps.length + 1)
        newProps.push prop

      newProps

    DecisionAidUserProperty.normalize_patient_weights = (properties) ->
      totalWeight = _.reduce properties, ((memo, property) -> memo + property.weight), 0
      propertyWeightHash = {}
      _.each properties, (p) =>
        propertyWeightHash[p.property_id] = p.weight / totalWeight
      propertyWeightHash

    DecisionAidUserProperty.generateSampleUserProperties = (n, properties, colors) ->
      sampleUserProps = []
      for i in [0...n]
        sampleProp = 
          property_id: properties[i].id
          weight: ((i + 1) * 100) / n
          property_title: properties[i].title
          order: i
          color: colors[i]
        sampleUserProps.push sampleProp
      sampleUserProps

    return DecisionAidUserProperty
  ]
