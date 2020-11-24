'use strict'

module = angular.module('dcida20App')

class UserEditCtrl
  @$inject: ['$scope', '$rootScope', '$state', '$stateParams', 'User', 'moment', 'Confirm', 'Sortable']
  constructor: (@$scope, @$rootScope, @$state, @$stateParams, @User, @moment, @Confirm, @Sortable) ->
    if @$scope.ctrl? && @$scope.ctrl.user?
      @currentUser = @$scope.ctrl.user

    @$scope.$on 'dcida.userChanged', (e, user) =>
      @currentUser = user

    @$scope.ctrl = @
    @loading = true

    if @$stateParams.userId
      @getUser(@$stateParams.userId)
      @isNewUser = false
      @title = "Edit User"
    else
      @user = new @User
      @isNewUser = true
      @loading = false
      @title = "New User"

  getUser: (userId) ->
    @User.get {id: userId}, (user) =>
      @loading = false
      @user = user

  saveUser: () ->
    if @isNewUser
      @user.$save {}, ((user) =>
        if user.id is @currentUser.id
          @$rootScope.$broadcast 'dcida.userChanged', user
        @$state.go "userList"
      )
    else
      @user.$update {}, ((user) =>
        if user.id is @currentUser.id
          @$rootScope.$broadcast 'dcida.userChanged', user
        @$state.go "userList"
      )

  deleteUser: () ->
    @Confirm.show(
      message: 'Are you sure you want to delete this user?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @user.$delete {}, (() => 
        @$state.go 'userList'
     ),((error) => 
        alert("User deletion failed")
      )


module.controller 'UserEditCtrl', UserEditCtrl
  


