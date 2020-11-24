'use strict'

# module that abstracts local storage of simple data.
# Essential for storing persistent client side values, such as access token and user id.
# For each key specified in the keys object, a getter and setter function will be generated.
# Example: for key currentFilter, a function Storage.getCurrentFilter() and Storage.setCurrentFilter(value) are available.
#
# The current implementation uses localStorage to perform persistence. It has been found that this feature does not work in
# private browsing mode of mobile safari. If this is an issue, it may need to be migrated to ngCookies library which uses
# cookies to store client side data. See https://docs.angularjs.org/api/ngCookies

class Storage
  @$inject: ['$window', '_']
  constructor: (@$window, @_) ->
    @keys =
      accessToken: 'dcida-access-token'
      refreshToken: 'dcida-refresh-token'
      userId: 'dcida-user-id'
      userEmail: 'dcida-user-email'
      decisionAidUserId: 'dcida-decision-aid-user-id'
      decisionAidSlug: 'dcida-decision-aid-slug'
      decisionAidTheme: 'dcida-decision-aid-theme'

    @_.each @keys, (key, name) =>
      underscored = @_.underscored name
      getter = @_.camelize "get_#{underscored}"
      setter = @_.camelize "set_#{underscored}"

      @[getter] = =>
        @valueForKey key

      @[setter] = (value) =>
        @setValueForKey key, value

  valueForKey: (key) ->
    @$window.localStorage.getItem key

  setValueForKey: (key, value) ->
    if value?
      @$window.localStorage.setItem key, value
    else
      @removeValueForKey key

  removeValueForKey: (key) ->
    @$window.localStorage.removeItem @keys[key]

  clearFrontEndData: () ->
    @removeValueForKey('decisionAidUserId')

  clearBackendData: () ->
    @removeValueForKey('accessToken')
    @removeValueForKey('refreshToken')
    @removeValueForKey('userId')
    @removeValueForKey('userEmail')
    @removeValueForKey('decisionAidSlug')
    @removeValueForKey('decisionAidTheme')

  clear: ->
    @_.each @keys, (key, name) =>
      @removeValueForKey @keys[key]

angular.module('dcida20App').service 'Storage', Storage
