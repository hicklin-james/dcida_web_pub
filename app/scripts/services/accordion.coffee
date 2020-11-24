'use strict'

angular.module('dcida20App')
  .factory 'Accordion', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['title', 'decision_aid_id', 'accordion_contents_attributes']
    actions = Util.resourceActions 'accordion', 'accordions', attributes

    Accordion = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/accordions/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    Accordion.prototype.initialize = () ->
      @accordion_contents = []

    Accordion.prototype.sanitizeForSubmit = () ->
      @accordion_contents_attributes = @accordion_contents
      _.each @accordion_contents_attributes, (ac) =>
        ac.decision_aid_id = @decision_aid_id

    return Accordion
  ]
