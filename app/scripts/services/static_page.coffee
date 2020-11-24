'use strict'

angular.module('dcida20App')
  .factory 'StaticPage', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['page_text', 'page_title', 'static_page_order', 'page_slug']
    actions = Util.resourceActions 'static_page', 'static_pages', attributes

    StaticPage = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/static_pages/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    StaticPage.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/static_pages/#{@id}/update_order", {static_page: @})
        .success((data) ->
          d.resolve(data.static_page)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    return StaticPage
  ]
