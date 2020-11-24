'use strict'

angular.module('dcida20App')
  .factory 'IntroPage', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['description']
    actions = Util.resourceActions 'intro_page', 'intro_pages', attributes

    IntroPage = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/intro_pages/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    IntroPage.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/intro_pages/#{@id}/update_order", {intro_page: @})
        .success((data) ->
          d.resolve(data.intro_page)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    IntroPage.preview = (decisionAidId) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/decision_aids/#{decisionAidId}/intro_pages/preview")
        .success((data) ->
          d.resolve(data.intro_pages)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return IntroPage
  ]
