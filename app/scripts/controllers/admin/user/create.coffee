'use strict'

module = angular.module('dcida20App')

class UserCreateCtrl
  @$inject: ['$scope', '$rootScope', 'Auth', '$state', '$stateParams', 'User', 'moment', 'Confirm', 'Sortable', '$uibModal']
  constructor: (@$scope, @$rootScope, @Auth, @$state, @$stateParams, @User, @moment, @Confirm, @Sortable, @$uibModal) ->
    @$scope.ctrl = @
    @loading = true

    @title = "Create User"
    @createToken = @$stateParams.createToken
    @loading = false
    @user = new @User
    @user.email = @$stateParams.email

  saveUser: () ->
    @errors = null
    @user.$save {creation_token: @$stateParams.createToken}, ((user) =>
      @Auth.signOut().then () =>
        @$state.go "signin"
    ), ((error) =>
      if error and error.data and error.data.errors
        @errors = error.data.errors
    )

  readTerms: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "views/admin/user/terms_of_service.html"
      controller: "TermsOfServiceCtrl"
      size: 'lg'
      )

    modalInstance.result.then (question) =>
      console.log "Terms read!"
      @termsRead = true

module.controller 'UserCreateCtrl', UserCreateCtrl
  


