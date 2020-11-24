'use strict'

module = angular.module('dcida20App')

class SigninCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth']
  constructor: (@$scope, @$state, @$location, @Auth) ->
    @loading = false
    @alert = null

    if @Auth.hasToken()
     @$state.go 'decisionAidList'

    @credentials = 
      email: ''
      password: ''

    @$scope.ctrl = @

    #if @Auth.hasToken()
    #  @$state.go 'decisionAidList'
    
  signIn: () ->
    @Auth.signIn(@credentials.email, @credentials.password).then (user) =>
      @$state.go 'decisionAidList'
    ,(error) =>
      @errorCode = error

module.controller 'SigninCtrl', SigninCtrl

