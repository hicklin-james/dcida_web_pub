'use strict'

angular.module('dcida20App')
  .factory 'LatentClass', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['id']
    actions = Util.resourceActions 'latent_class', 'latent_classes', attributes

    LatentClass = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/latent_classes/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    LatentClass.prototype.initialize = (decisionAidId, options, properties) ->
      @decision_aid_id = decisionAidId
      @latent_class_properties = {}
      @latent_class_options = {}
      
      _.each options, (o) =>
        @latent_class_options[o.id] = {
          weight: 0,
          option_id: o.id
        }

      _.each properties, (p) =>
        @latent_class_properties[p.id] = {
          weight: 0,
          property_id: p.id
        }

    LatentClass.prototype.setup = (options, properties) ->
      @latent_class_options = {}
      @latent_class_properties = {}

      _.each @latent_class_options_arr, (o) =>
        @latent_class_options[o.option_id] = {
          weight: o.weight,
          option_id: o.option_id
        }

      _.each @latent_class_properties_arr, (p) =>
        @latent_class_properties[p.property_id] = {
          weight: p.weight,
          property_id: p.property_id
        }

    LatentClass.prepareForUpdate = (latent_classes) ->
      orderCount = 1
      # remove those that are destroyed and not saved
      filtered_classes = _.reject latent_classes, (lc) ->
        lc._destroy && !lc.id
      _.each filtered_classes, (lc) =>
        if !lc._destroy
          lc.class_order = orderCount
          orderCount += 1
        lc.latent_class_options_attributes = []
        lc.latent_class_properties_attributes = []
        _.each lc.latent_class_options, (v) =>
          lc.latent_class_options_attributes.push v
        _.each lc.latent_class_properties, (v) =>
          lc.latent_class_properties_attributes.push v



    LatentClass.createAndUpdateAndDeleteBulk = (decision_aid_id, latent_classes) ->
      d = $q.defer()
      @prepareForUpdate(latent_classes)
      params = latent_classes
      #console.log params
      $http.post("#{API_ENDPOINT}/decision_aids/#{decision_aid_id}/latent_classes/create_and_update_and_delete_bulk", {latent_classes: params})
        .success((data) ->
          #data.$metadata = data.meta
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise


    return LatentClass
  ]
