'use strict'

class Auth
  @$inject: ['$q', '$http', '$rootScope', '$window', 'API_ENDPOINT', 'OAUTH_ENDPOINT', 'Storage', 'User']
  constructor: (@$q, @$http, @$rootScope, @$window, @API_ENDPOINT, @OAUTH_ENDPOINT, @Storage, @User) ->

  hasToken: () ->
    @Storage.getAccessToken()?

  currentUserId: ->
    @Storage.getUserId()

  setUser: (user) ->
    if user
      @Storage.setUserId user.id
      @Storage.setUserEmail user.email
      @$rootScope.$broadcast 'dcida.userChanged', user
    else
      @Storage.clear()

  decisionAidFound: (decisionAid, pages, decisionAidUser) ->
    data =
      decisionAid: decisionAid
      pages: pages
      decisionAidUser: decisionAidUser
    @$rootScope.$broadcast 'dcida.decisionAidFound', data

  getDecisionAidUser: (params) ->
    d = @$q.defer()
    @$http.get("#{@API_ENDPOINT}/decision_aid_home/get_decision_aid_user", params: params)
      .success((data) ->
        d.resolve(data)
      )
      .error((data) ->
        d.reject(data)
      )
    d.promise

  # given user credentials, retrieve an access token
  getToken: (email, password) ->
    d = @$q.defer()
    data = {email:email, password:password, grant_type: 'password'}
    @$http(method: 'POST', url: "#{@OAUTH_ENDPOINT}/token", data: data, ignoreAuthModule: true)
      .success (data) =>
        @Storage.setAccessToken data.access_token
        @Storage.setRefreshToken data.refresh_token
        d.resolve data
      .error (data, status) =>
        d.reject(status)
    d.promise

  currentUser: () ->
    d = @$q.defer()
    @$http.get("#{@API_ENDPOINT}/users/current")
      .success (data) =>
        @setUser(data.user)
        d.resolve(data.user)
      .error (data, status, headers, config) =>
        d.reject(status)
    d.promise


  signIn: (email, password) ->
    d = @$q.defer()
    @getToken(email, password).then (data) =>
      @currentUser().then (user) =>
        user = new @User user
        @setUser(user)
        d.resolve(user)
      ,(error) =>
        d.reject(error)
    ,(error) =>
      d.reject(error)
    d.promise

  signOut: () ->
    d = @$q.defer()
    @$http(method: 'POST', url: "#{@OAUTH_ENDPOINT}/revoke", ignoreAuthModule: true)
      .success (data) =>
        @Storage.clearBackendData()
        d.resolve(data)
      .error (data, status) =>
        d.reject(status)
    d.promise

angular.module('dcida20App').service 'Auth', Auth