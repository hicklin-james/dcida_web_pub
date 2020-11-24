'use strict'

module = angular.module('dcida20App')

class UserNewCtrl
  @$inject: ['$scope', '$rootScope', '$state', '$stateParams', 'UserAuthentication', 'moment', 'Confirm', 'Sortable']
  constructor: (@$scope, @$rootScope, @$state, @$stateParams, @UserAuthentication, @moment, @Confirm, @Sortable) ->
    @$scope.ctrl = @
    @userAuth = new @UserAuthentication

    @title = "Invite User"

  sendUserCreationEmail: () ->
    @errors = null
    @userAuth.$save {user_email: @user_email}, ((userAuth) =>
      @Confirm.alert(
        message: "Success"
        headerClass: "text-success"
        messageSub: "Email sent to " + userAuth.email + " with instructions on how to activate their account."
        buttonType: "default"
      )
    ), ((error) =>
      if error? and error.data? and error.data.errors?
        @errors = error.data.errors
    )


module.controller 'UserNewCtrl', UserNewCtrl
  


