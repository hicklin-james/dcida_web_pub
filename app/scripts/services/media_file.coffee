'use strict'

angular.module('dcida20App')
  .factory 'MediaFile', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = []
    actions = Util.resourceActions 'media_file', 'media_files', attributes

    MediaFile = $resource "#{API_ENDPOINT}/users/:user_id/media_files/:id", { id: '@id', user_id: '@user_id' }, actions

    return MediaFile
  ]
