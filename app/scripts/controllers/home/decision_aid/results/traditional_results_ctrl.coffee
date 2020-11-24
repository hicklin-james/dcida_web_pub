angular.module('dcida20App')
  .factory 'TraditionalResultsCtrl', ['$q', '$timeout', '_', 'Util', 'DecisionAidUserProperty', '$uibModal', ($q, $timeout, _, Util, DecisionAidUserProperty, $uibModal) ->
    class TraditionalResultsCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, @optionPropertyHash) ->
        if @resultMatchOption
          @options = _.sortBy(@options, (o) => @resultMatchOption[o.id]).reverse()
        @visibleOptions = _.first @options, 3
        @getPropertyColorGradient(@properties.length)

        @scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
          bootstro.stop()

      getPropertyColorGradient: (n) ->
        rainbow = new Rainbow()
        rainbow.setNumberRange(1, n)
        rainbow.setSpectrum("#c2d0c5", "#229c3d")
        @rainbowColors = _.map [1..5], (p, i) => 
          rgb = Util.hexToRgb(rainbow.colorAt(i))
          "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.7)"

      generateDecisionAidUserOptionPropertiesHash: () ->
        d = $q.defer()

        DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id}, (userProps) =>
          @userProps = userProps
          @userPropsHash = _.indexBy @userProps, 'property_id'
          d.resolve()
        , (error) =>
          d.reject()

        d.promise

      setupTraditionalUserProperties: () ->
        if @userProps.length isnt @properties.length
          nextProperty = _.find (_.sortBy @properties, 'property_order'), (prop) => !@userPropsHash[prop.id]

          # console.log nextProperty
          @openTraditionalUserPropsWindow(nextProperty if @userProps.length isnt 0)
        else
          @orderPropertiesBasedOnUserProps(@userProps)

      orderPropertiesBasedOnUserProps: (userProperties) ->
        @userProps = userProperties
        @userPropsHash = _.indexBy @userProps, 'property_id'
        
        @sortedProperties = _(@properties).chain()
          .sortBy('property_order')
          .sortBy((p) => if @userPropsHash[p.id] then -@userPropsHash[p.id].traditional_value else null)
          .value()

      openTraditionalUserPropsWindow: (currentProperty = null) ->
        bootstro.stop()
        completed = @userProps.length is @properties.length
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
        )

        modalInstance.result.then (userProperties) =>
          @orderPropertiesBasedOnUserProps(userProperties)
          if !@scope.$$phase 
            @scope.$digest()

      getHelp: () ->
        bootstro.start(".bootstro", {finishButtonText: 'Close help'})

      prevState: () ->
        if @decisionAid.demographic_questions_count == 0
          stateName: "decisionAidIntro"
        else
          stateName: "decisionAidAbout"
  ]