'use strict'

module = angular.module('dcida20App')

class DecisionAidPropertiesDecideCtrl
  @$inject: ['$scope', '$document', 'Confirm', '$timeout', '$state', '$stateParams', 'DecisionAidHome', 'DecisionAidUserProperty', 'DecisionAidUserOptionProperty', 'moment', 'Auth', '_', 'NavBroadcastService', 'themeConfig', '$translate', 'StateChangeRequested', '$q', 'DecisionAidUser']
  constructor: (@$scope, @$document, @Confirm, @$timeout, @$state, @$stateParams, @DecisionAidHome, @DecisionAidUserProperty, @DecisionAidUserOptionProperty, @moment, @Auth, @_, @NavBroadcastService, @themeConfig, @$translate, @StateChangeRequested, @$q, @DecisionAidUser) ->
    @$scope.ctrl = @

    @$scope.$on 'decisionAidInvalid', () =>
      @invalidDecisionAid()

    @$scope.$
      
    @loading = true
    @NavBroadcastService.emitLoadingToRoot(true, @$scope)
    @StateChangeRequested.subscribeToStateChange(@$scope)

    @colors = @themeConfig["COLORS"]
    @nameValueMap = {
      0: "Unsure",
      1: "Not important",
      2: "Slightly important",
      3: "Important",
      4: "Very important"
    }

    @decisionAidSlug = @$stateParams.slug

    @decisionAid = null
    @propertiesHash = {}

    @DecisionAidHome.propertiesDecide(@decisionAidSlug).then ((data) =>
      @decisionAid = data.decision_aid
      @decisionAidUser = new @DecisionAidUser(data.meta.decision_aid_user)
      #@decisionAidUser.initialize(data.meta.decision_aid_user)
      @properties = data.decision_aid.properties
      @indexedProperties = @_.indexBy @properties, "id"

      @DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id}, (decisionAidUserProperties) =>
        @propertiesHash = @_.indexBy(decisionAidUserProperties, 'property_id')
        @_.each @propertiesHash, (up) ->
          up.hidden = true

        @Auth.decisionAidFound(@decisionAid, data.meta.pages, @decisionAidUser)
        @NavBroadcastService.emitLoadingToRoot(false, @$scope)

      , (error) =>
        @invalidDecisionAid()
    ),
    ((error) =>
      @invalidDecisionAid()
    )

  setUserProperty: (prop, value) ->
    if @propertiesHash[prop.id]?
      @propertiesHash[prop.id].weight = value
    else
      newProperty = new @DecisionAidUserProperty
      newProperty.initialize(prop, @decisionAidUser, @_.toArray(@propertiesHash).length)
      newProperty.color = "#ffffff"
      newProperty.weight = value
      newProperty.hidden = true
      @propertiesHash[prop.id] = newProperty

  invalidDecisionAid: () ->
    @decisionAid = null
    @noDecisionAidFound = true
    @NavBroadcastService.emitLoadingToRoot(false, @$scope)

  submitNext: () ->
    selections = @_.toArray(@propertiesHash)
    if selections.length < @properties.length
      @$translate(['OOPS', 'MUST-SELECT-ALL-PROPERTIES']).then (translations) =>
        @Confirm.warning(
          message: translations['OOPS'],
          messageSub: translations['MUST-SELECT-ALL-PROPERTIES'],
          buttonType: "default"
        )
    else
      @loading = true
      @NavBroadcastService.emitLoadingToRoot(true, @$scope)

      #p1 = @DecisionAidUserProperty.updateSelections(selections, @decisionAidUser.id)
      #p2 = @decisionAidUser.$update()

      #promises = [p1.$promise, p2.$promise]
      #p1.
      #@$q.all(promises).then (resolvedPromises) =>
      #@DecisionAidUserProperty.updateSelections(selections, @decisionAidUser.id).then (decisionAidUserProperties) =>
      @DecisionAidUserProperty.updateSelections(selections, @decisionAidUser.id).then (decisionAidUserProperties) =>
        @decisionAidUser.updateFromProperties().then () =>
          if @decisionAid.quiz_questions_count > 0
            @$state.go "decisionAidQuiz", {slug: @decisionAidSlug}
          else
            @$state.go "decisionAidSummary", {slug: @decisionAidSlug}
        ,(error) =>
          console.log error
      ,(error) =>
        console.log error
      
  prevLink: () ->
    if @decisionAid.demographic_questions_count == 0
      @$state.go("decisionAidIntro", {slug: @decisionAidSlug, back: true})
    else
      @$state.go "decisionAidAbout", {slug: @decisionAidSlug, back: true}



module.controller 'DecisionAidPropertiesDecideCtrl', DecisionAidPropertiesDecideCtrl
