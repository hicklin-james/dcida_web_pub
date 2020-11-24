'use strict'

module = angular.module('dcida20App')

class DecisionAidNewCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAid', 'ErrorHandler']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAid, @ErrorHandler) ->
    @$scope.ctrl = @

    @title = "New Decision Aid"
    @decisionAid = new @DecisionAid
    @decisionAid.title = ""
    @decisionAid.decision_aid_type = 'standard'

    @decisionAidTypes = [
      {key: "standard", label: "Standard"},
      {key: "treatment_rankings", label: "Treatment Rankings"},
      {key: "dce", label: "DCE"},
      {key: "best_worst", label: "Best Worst"},
      {key: "traditional", label: "Traditional"},
      {key: "best_worst_no_results", label: "Simplified Best Worst"},
      {key: "risk_calculator", label: "Risk Calculator"},
      {key: "traditional_no_results", label: "Traditional No Results"},
      {key: "dce_no_results", label: "Simplified DCE"},
      {key: "best_worst_with_prefs_after_choice", label: "Rebecca's Best Worst"},
      {key: "standard_enhanced", label: "Enhanced ANSWER2 theme"},
      {key: "decide", label: "DECIDE Genome"}
    ]

  setDecisionAidType: (dat) ->
    @decisionAid.decision_aid_type = dat.key

  # MARK - Not implemented yet
  #handleError: (error) -> 
  #  @errors = @ErrorHandler.handleError(error)
    #if data = error.data
    #  if errors = data.errors
    #    @errors = errors

  saveDecisionAid: () ->
    if @$scope.decisionAidEditForm.$valid
      @decisionAid.$save ((decisionAid) => 
        @$state.go "decisionAidShow", {decisionAidId: decisionAid.id}
      ), ((error) => 
        console.log error
        @errors = @ErrorHandler.handleError(error)
        console.log @errors
      )

module.controller 'DecisionAidNewCtrl', DecisionAidNewCtrl

