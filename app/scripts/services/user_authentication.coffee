'use strict'

angular.module('dcida20App')
  .factory 'UserAuthentication', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['is_superuser', 'email']
    actions = Util.resourceActions 'user_authentication', 'user_authentications', attributes

    UserAuth = $resource "#{API_ENDPOINT}/user_authentications/:id", { id: '@id' }, actions

    UserAuth.reset_password = (email) ->
      ua = new UserAuth
      ua.email = email
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/user_authentications/reset_password", {user_authentication: ua})
        .success((data) ->
          d.resolve(data.user_authentication)
        )
        .error((data) ->
          d.reject(data.errors)
        )
      d.promise

    return UserAuth
  ]
