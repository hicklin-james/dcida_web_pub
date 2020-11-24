'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidUserOptionProperty', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', 'DecisionAidUserProperty', ($resource, $http, _, $q, API_ENDPOINT, Util, DecisionAidUserProperty) ->
    attributes = ['id', 'property_id', 'decision_aid_user_id', 'option_id', 'option_property_id', 'value']
    actions = Util.resourceActions 'decision_aid_user_option_property', 'decision_aid_user_option_properties', attributes

    DecisionAidUserOptionProperty = $resource "#{API_ENDPOINT}/decision_aid_users/:decision_aid_user_id/decision_aid_user_option_properties/:id", { id: '@id', decision_aid_user_id: '@user_id' }, actions

    DecisionAidUserOptionProperty.prototype.initialize = (option_property, decision_aid_user) ->
      @property_id = option_property.property_id
      @option_id = option_property.option_id
      @option_property_id = option_property.id
      @decision_aid_user_id = decision_aid_user.id
      @value = if option_property.ranking then option_property.ranking else 0
      @submitted = if @value then true else false
    
    DecisionAidUserOptionProperty.sanitizeForUpdate = (option_properties) ->
      props = angular.copy option_properties
      _.each props, (property) =>
        _.each property, (value, k) =>
          if _.indexOf(attributes, k) == -1
            delete property[k]
      props      

    DecisionAidUserOptionProperty.updateUserOptionProperties = (option_properties, decision_aid_user_id) ->
      d = $q.defer()
      params = 
        option_properties: @sanitizeForUpdate(option_properties)
      $http.post("#{API_ENDPOINT}/decision_aid_users/#{decision_aid_user_id}/decision_aid_user_option_properties/update_user_option_properties", 
                 decision_aid_user_option_properties: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAidUserOptionProperty.createMissingOptionProperties = (dauops, option_props, decision_aid_user) ->
      difference = _.filter option_props, (op) => !_.find dauops, (dauop) => dauop.option_property_id is op.id
      newOptionProps = []
      _.each difference, (op) =>
        prop = new DecisionAidUserOptionProperty()
        prop.initialize(op, decision_aid_user)
        newOptionProps.push prop

      newOptionProps

    DecisionAidUserOptionProperty.filterUnsubmittedProps = (uops) ->
      filteredUops = {}
      _.each uops, (v, k) ->
        filteredUops[k] = {}
        _.each v, (vv, kk) ->
          if vv.submitted
            filteredUops[k][kk] = vv
      filteredUops

    DecisionAidUserOptionProperty.calculateTreatmentPercentages = (patient, decisionAid, userProperties, userOptionPropertiesHash, options, properties) ->
      propertyWeightHash = DecisionAidUserProperty.normalize_patient_weights userProperties
      filteredOptionPropertiesHash = @filterUnsubmittedProps(userOptionPropertiesHash)
      optionTotals = {}
      totalSum = 0
      _.each filteredOptionPropertiesHash , (v, k) ->
        _.each v, (uop) ->
          #console.log uop
          normalizedWeight = if propertyWeightHash[k] then propertyWeightHash[k] else 0.001
          totalSum += (uop.value * normalizedWeight)
          if !optionTotals[uop.option_id]?
            optionTotals[uop.option_id] = (uop.value * normalizedWeight)
          else
            optionTotals[uop.option_id] += (uop.value * normalizedWeight)

      maxSum = -1
      maxSumTreatment = null
      _.each optionTotals, (v, k) -> 
        if v > maxSum
          maxSum = v
          maxSumTreatment = k

      unratedProps = _.filter properties, (p) -> _.isEmpty filteredOptionPropertiesHash[p.id]
      maxOptionTotals = angular.copy optionTotals
      delete maxOptionTotals[maxSumTreatment]

      _.each maxOptionTotals, (oT, k) ->
        maxPossibleRemainder = _.reduce unratedProps, (memo, p) -> 
          memo + (if propertyWeightHash[p.id] then 10 * propertyWeightHash[p.id] else 10 * 0.001)
        , 0
        maxOptionTotals[k] = oT + maxPossibleRemainder

      bestTreatment = null
      #console.log maxOptionTotals
      #console.log maxSum
      if _.every(maxOptionTotals, (t) -> t < maxSum) or decisionAid.decision_aid_type is "treatment_rankings"
        bestTreatment = _.find options, (o) -> o.id is parseFloat(maxSumTreatment)

      heights = {}
      _.each optionTotals, (oT, k) ->
        heights[k] = (oT / totalSum) * 100

      
      #console.log {heights: heights, bestTreatment: bestTreatment}
      {heights: heights, bestTreatment: bestTreatment}


    return DecisionAidUserOptionProperty
  ]
