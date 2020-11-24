angular.module('dcida20App')
  .factory 'TraditionalNoRankingsResultsCtrl', ['$q', '$timeout', '_', 'Util', 'DecisionAidUserProperty', '$uibModal', ($q, $timeout, _, Util, DecisionAidUserProperty, $uibModal) ->
    class TraditionalNoRankingsResultsCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, @optionPropertyHash) ->
        @visibleOptions = _.first @options, 3

      generateDecisionAidUserOptionPropertiesHash: () ->
        d = $q.defer()

        DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id}, (userProps) =>
          @userProps = userProps
          @userPropsHash = _.indexBy @userProps, 'property_id'
          @sortedProperties = _.sortBy @properties, (p) => @userProps[p.id]?
          d.resolve()
        , (error) =>
          d.reject()

        d.promise

      openTraditionalUserPropsWindow: (currentProperty = null) ->
        completed = true
        dontSaveOnClose = true
        modalInstance = $uibModal.open(
          templateUrl: "/views/home/decision_aid/traditional_user_props.html"
          controller: "TraditionalUserPropertyCtrl"
          size: 'giant'
          backdrop: if completed then true else 'static'
          resolve:
            options: () =>
              properties: @properties
              optionProperties: @optionPropertyHash
              userProps: @userProps
              decisionAidUser: @decisionAidUser
              options: @options
              currentProperty: currentProperty
              decisionAid: @decisionAid
              completed: completed
              dontSaveOnClose: dontSaveOnClose
        )

      prevState: () ->
        stateName: "decisionAidTraditionalProperties"
  ]