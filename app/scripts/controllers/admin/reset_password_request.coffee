'use strict'

module = angular.module('dcida20App')

class ResetPasswordRequestCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'UserAuthentication']
  constructor: (@$scope, @$state, @$location, @Auth, @UserAuthentication) ->
    @loading = false

    @email = ""
    @$scope.ctrl = @

  requestReset: () ->
    @UserAuthentication.reset_password(@email).then (userAuth) =>
      @userAuth = userAuth
    , (errors) =>
      @errors = errors

module.controller 'ResetPasswordRequestCtrl', ResetPasswordRequestCtrl

