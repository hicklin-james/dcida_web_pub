'use strict'

module = angular.module('dcida20App')

class SigninModalCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', '$uibModalInstance']
  constructor: (@$scope, @$state, @$location, @Auth, @$uibModalInstance) ->
    @loading = false
    @alert = null

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      @$uibModalInstance.dismiss()

    @credentials = 
      email: ''
      password: ''

    @$scope.ctrl = @
    # need to parseint because it is stored in browser storage as a string
    @currUserId = parseInt(@Auth.currentUserId())
    
  signIn: () ->
    @Auth.signIn(@credentials.email, @credentials.password).then (user) =>
      if parseInt(user.id) isnt parseInt(@currUserId)
        @$state.go 'decisionAidList'
      @$uibModalInstance.close()
    ,(error) =>
      @errorCode = error


module.controller 'SigninModalCtrl', SigninModalCtrl

