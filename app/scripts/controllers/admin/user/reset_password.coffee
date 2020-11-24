'use strict'

module = angular.module('dcida20App')

class ResetPasswordCtrl
  @$inject: ['$scope', '$rootScope', 'Auth', '$state', '$stateParams', 'User']
  constructor: (@$scope, @$rootScope, @Auth, @$state, @$stateParams, @User) ->
    @$scope.ctrl = @
    @loading = true

    @resetToken = @$stateParams.resetToken
    @loading = false
    @user = new @User
    @user.email = @$stateParams.email

    @user.password = ""
    @user.password_confirmation = ""

  resetPassword: () ->
    @user.resetPassword(@resetToken).then (user) =>
      @user = user
    , (errors) =>
      @errors = errors

module.controller 'ResetPasswordCtrl', ResetPasswordCtrl
  


