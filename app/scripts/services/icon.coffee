'use strict'

angular.module('dcida20App')
  .factory 'Icon', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = []
    actions = Util.resourceActions 'icon', 'icons', attributes

    Icon = $resource "#{API_ENDPOINT}/decision_aids/:decision_aid_id/icons/:id", { id: '@id', decision_aid_id: '@decision_aid_id' }, actions

    Icon.sanitizeForUpdate = (icons) ->
      _.map icons, (icon) -> { id: icon.id, url: icon.url }

    Icon.massUpdate = (icons, decision_aid_id) ->
      sanitizedIcons = @sanitizeForUpdate icons
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/decision_aids/#{decision_aid_id}/icons/update_bulk", icons: sanitizedIcons)
        .success((data) ->
          d.resolve(data.icons)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return Icon
  ]
