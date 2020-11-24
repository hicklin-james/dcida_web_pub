'use strict'

angular.module('dcida20App')
  .factory 'QuestionPage', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = [ 'section', 'question_page_order', 'skip_logic_targets_attributes' ]
    actions = Util.resourceActions 'question_page', 'question_pages', attributes

    QuestionPage = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/question_pages/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    QuestionPage.prototype.prepareSkipLogicDataForSave = (deletedSlts, deletedSlcs) ->
      _.each @skip_logic_targets, (slt, ind) =>
        slt.skip_logic_target_order = ind
        _.each slt.skip_logic_conditions, (slc, indd) =>
          slc.skip_logic_condition_order = indd

      @skip_logic_targets_attributes = @skip_logic_targets
      @skip_logic_targets = []

      _.each @skip_logic_targets_attributes, (slt) =>
        slt.skip_logic_conditions_attributes = slt.skip_logic_conditions
        if deletedSlcs and deletedSlcs[slt.id]
          slt.skip_logic_conditions_attributes = slt.skip_logic_conditions_attributes.concat(deletedSlcs[slt.id])
        slt.skip_logic_conditions = []

      if deletedSlts and deletedSlts.length > 0
        @skip_logic_targets_attributes = @skip_logic_targets_attributes.concat(deletedSlts)

    QuestionPage.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/question_pages/#{@id}/update_order", {question_page: @})
        .success((data) ->
          d.resolve(data.question_page)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    return QuestionPage
  ]
