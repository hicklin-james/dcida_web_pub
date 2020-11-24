'use strict'

module = angular.module('dcida20App')

module.filter 'underscoreless', () ->
  (input) ->
    input.replace(/_/g, ' ')

module.filter 'capitalize', (_) ->
  (input, scope) ->
    if input
      inputs = input.split(" ")
      inputs = _.map inputs, (inp) => 
        inp.substring(0,1).toUpperCase()+inp.substring(1)
      inputs.join " "
###*
 # @ngdoc controller
 # @name dcida20App.controller:DecisionAidListCtrl
 # @description
 # # DecisionAidListCtrl
 # Decision Aid List controller for DCIDA admin. Displays list of decision aids
 # that the user has access to.
###

class DecisionAidListCtrl
  @$inject: ['$scope', '$state', 'DecisionAid', 'moment', 'Confirm', 'Sortable', 'Auth']
  constructor: (@$scope, @$state, @DecisionAid, @moment, @Confirm, @Sortable, @Auth) ->
    @$scope.ctrl = @
    @loading = true
    @getDecisionAids()

  ###*
  # @ngdoc method
  # @name DecisionAidListCtrl#getDecisionAids
  # @methodOf dcida20App.controller:DecisionAidListCtrl
  # @description
  # Responsible for populating the decisionAids controller variable with an array of {@link dcida20App.service:DecisionAid DecisionAids}
  # @returns {$resource} An angular {@link https://docs.angularjs.org/api/ngResource/service/$resource $resource} instance
  ###
  getDecisionAids: () ->
    @DecisionAid.query (decisionAids) =>
      @loading = false
      @decisionAids = decisionAids

  deleteDecisionAid: (decisionAid) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this decision aid?'
      messageSub: 'All data that has been collected with this decision aid will be destroyed alongside the decision aid.'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      decisionAid.$delete {}, (() => 
        @Sortable.finishItemDeletion(decisionAid, @decisionAids)
        #@finishItemDeletion(option, "options", "option_order")
     ),((error) => 
        console.log("Decision aid deletion failed")
      )


module.controller 'DecisionAidListCtrl', DecisionAidListCtrl
  


