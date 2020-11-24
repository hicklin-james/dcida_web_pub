'use strict'

angular.module('dcida20App')
  .factory 'User', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['first_name', 'last_name', 'is_superadmin', 'password', 'email', 'password_confirmation', 'terms_accepted']
    actions = Util.resourceActions 'user', 'users', attributes

    User = $resource "#{API_ENDPOINT}/users/:id", { id: '@id' }, actions

    User.prototype.resetPassword = (token) ->
      d = $q.defer()
      $http.post("#{API_ENDPOINT}/users/reset_password", {user: @, token: token})
        .success((data) ->
          d.resolve(new User(data.user))
        )
        .error((data) ->
          d.reject(data.errors)
        )
      d.promise

    return User
  ]
