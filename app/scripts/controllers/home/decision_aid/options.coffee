'use strict'

module = angular.module('dcida20App')

class DecisionAidOptionsCtrl
  @$inject: ['$scope', '$state', '$stateParams', 'DecisionAidHome', 'moment', 'Auth']
  constructor: (@$scope, @$state, @$stateParams, @DecisionAidHome, @moment, @Auth) ->
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @decisionAid = null
      @loading = false

    @decisionAidSlug = @$stateParams.slug
    @decisionAid = null
    @loading = true

    @subDecisionOrder = if @$stateParams.sub_decision_order then parseInt(@$stateParams.sub_decision_order) else 1

    @DecisionAidHome.options(@decisionAidSlug, @subDecisionOrder).then ((data) =>
      @decisionAid = data.decision_aid
      @decisionAidUser = data.meta.decision_aid_user
      @subDecision = data.decision_aid.sub_decision
      @subDecisionOrder = @subDecision.sub_decision_order
      @options = data.decision_aid.relevant_options
      @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)
      @loading = false
    ),
    ((error) =>
      @loading = false
      @noDecisionAidFound = true
    )

  submitNext: () ->
    if @subDecisionOrder is 1
      if @decisionAid.decision_aid_type is 'dce'
        @$state.go "decisionAidDce", {slug: @decisionAidSlug}
      else if @decisionAid.decision_aid_type is 'best_worst'
        @$state.go "decisionAidBestWorst", {slug: @decisionAidSlug}
      else if @decisionAid.decision_aid_type is 'traditional'
        @$state.go "decisionAidResults", {slug: @decisionAidSlug}
      else
        @$state.go "decisionAidProperties", {slug: @decisionAidSlug}
    else
      @$state.go "decisionAidResults", {slug: @decisionAidSlug, sub_decision_order: @subDecisionOrder}

  prevLink: () ->
    if @subDecisionOrder is 1
      @$state.go "decisionAidAbout", {slug: @decisionAidSlug}
    else
      @$state.go "decisionAidResults", {slug: @decisionAidSlug, sub_decision_order: @subDecisionOrder - 1}



module.controller 'DecisionAidOptionsCtrl', DecisionAidOptionsCtrl

