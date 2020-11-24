'use strict'

module = angular.module('dcida20App')

class UserListCtrl
  @$inject: ['$scope', '$state', 'User', 'moment', 'Confirm', 'Sortable']
  constructor: (@$scope, @$state, @User, @moment, @Confirm, @Sortable) ->
    if @$scope.ctrl? && @$scope.ctrl.user?
      @user = @$scope.ctrl.user

    @$scope.$on 'dcida.userChanged', (e, user) =>
      @user = user

    @$scope.ctrl = @
    @loading = true
    @getUsers()

  getUsers: () ->
    @User.query (users) =>
      @loading = false
      @users = users

  deleteUser: (user) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this user?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      user.$delete {}, (() => 
        @Sortable.finishItemDeletion(user, @users)
        #@finishItemDeletion(option, "options", "option_order")
     ),((error) => 
        alert("User deletion failed")
      )


module.controller 'UserListCtrl', UserListCtrl
  


