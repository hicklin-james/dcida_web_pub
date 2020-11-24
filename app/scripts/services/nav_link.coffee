'use strict'

angular.module('dcida20App')
  .factory 'NavLink', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['link_text', 'link_href', 'link_location', 'nav_link_order']
    actions = Util.resourceActions 'nav_link', 'nav_links', attributes

    NavLink = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/nav_links/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    NavLink.prototype.updateOrder = () ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{@decision_aid_id}/nav_links/#{@id}/update_order", {nav_link: @})
        .success((data) ->
          d.resolve(data.nav_link)
        )
        .error((data) ->
          d.reject()
        )
      d.promise

    return NavLink
  ]
