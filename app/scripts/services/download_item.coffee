'use strict'

angular.module('dcida20App')
  .factory 'DownloadItem', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->

    attributes = ['id']
    actions = Util.resourceActions 'download_item', 'download_items', attributes

    DownloadItem = $resource "#{API_ENDPOINT}/download_items/:id", { id: '@id' }, actions

    DownloadItem.downloadLatestItem = (download_type_param) ->
      d = $q.defer()
      $http.get("#{API_ENDPOINT}/download_items/latest_download_item", params: {download_type: download_type_param})
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DownloadItem

  ]
