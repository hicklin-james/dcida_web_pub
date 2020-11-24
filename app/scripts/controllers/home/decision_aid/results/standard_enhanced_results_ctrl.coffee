angular.module('dcida20App')
  .factory 'StandardEnhancedResultsCtrl', ['$q', '$timeout', '_', 'Util', 'DecisionAidUserOptionProperty', 'DecisionAidUserProperty', ($q, $timeout, _, Util, DecisionAidUserOptionProperty, DecisionAidUserProperty) ->
    class StandardEnhancedResultsCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, @resultMatchOption) ->
        
        @visibleOptions = _.first @options, 3
        @introJsOptions = 
          steps: [
            element: '#prop-row-info-0'
            intro: "Press the \"i\" to show additional information regarding this option property with respect to each option."
           ,
            element: '#prop-opt-0-0'
            intro: "Use the sliders to rate the option properties based on their information."
           ,
            element: '#results-row-0'
            intro: "When you have rated the entire row, DCIDA will determine whether an option can be calculated for you." 
          ]
          disableInteraction: true
          showStepNumbers: false

        currPropertyGrouping = undefined
        negnum = -1
        @displayedPropertiesWithGroupings = []
        _.each @properties, (prop, index) =>
          if prop.property_group_title isnt currPropertyGrouping
            currPropertyGrouping = prop.property_group_title
            p = {id: negnum, short_label: currPropertyGrouping, property_id: -1}
            @displayedPropertiesWithGroupings.push p
            negnum -= 1

          @displayedPropertiesWithGroupings.push prop

      calculateColor: (val) ->
        normalized_val = (val - 1) / (5 - 1)
        hue = (normalized_val * 100) * 1.2 / 360
        rgb = Util.hslToRgb(hue, 1, .5)
        "rgb(#{rgb[0]}, #{rgb[1]}, #{rgb[2]})"

      getHelp: () ->
        @askedForHelp = true
        # $timeout () =>
        #   @startIntroJs()
        # , 800

      createDauopsHash: (dauops) ->
        @askedForHelp = dauops.length > 0

        missingProps = DecisionAidUserOptionProperty.createMissingOptionProperties(dauops, @optionProperties, @decisionAidUser)
        combinedProps = dauops.concat missingProps

        @dauopsHash = {}
        _.each combinedProps, (op) =>
          
          @dauopsHash[op.property_id] = {} if !@dauopsHash[op.property_id]?

          @dauopsHash[op.property_id][op.option_id] = op
          op.color = @calculateColor(op.value)
          @dauopsHash[op.property_id][op.option_id].sliderOptions =
            step: 1
            start: (event, ui) =>
              if !op.submitted
                op.submitted = true
                op.value = 1
              if !@scope.$$phase
                @scope.$digest()
            stop: (event, ui) =>
              @submitRow(op.property_id)

      generateDecisionAidUserOptionPropertiesHash: () ->
        d = $q.defer()

        DecisionAidUserProperty.query {decision_aid_user_id: @decisionAidUser.id}, (userProps) =>
          @userProps = userProps
          oids = _.map(@options, (o) -> o.id)

          stringifiedRanks = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth", "Ninth", "Tenth", "Eleventh", "Twelfth"]

          DecisionAidUserOptionProperty.query {decision_aid_user_id: @decisionAidUser.id, 'option_ids[]': oids}, (dauops) =>
            @createDauopsHash(dauops)
            $timeout () =>
              #_.each @dauopsHash, (v, k) => @submitRow(k)
              @optionHeights = @resultMatchOption
              @bestTreatment = null
              max = -1
              _.each @optionHeights, (v, k) => 
                if v > max
                  max = v
                  @bestTreatment = k

              if @bestTreatment
                # we know scores already exist - find them and put best match at the start, or after the doctor
                # recommended option if it exists
                @options = _.sortBy @options, (o) =>
                  if @optionHeights[o.id] then @optionHeights[o.id] else 2
                .reverse()

                #@matchHash = {}
                _.each @options, (o, i) =>
                  o.stringifiedRank = stringifiedRanks[i] + " Matched Choice"

                adjustedOptions = []
                _.each @options, (o, i) =>
                  if o.ct_order
                    o.doctorRec = true
                    adjustedOptions.unshift(o)
                  else if o.id is @bestTreatment.id
                    if adjustedOptions.length > 0 and adjustedOptions[0].ct_order
                      adjustedOptions.splice(1,0,o)
                    else
                      adjustedOptions.unshift(o)
                  else
                    adjustedOptions.push(o)

                @options = adjustedOptions
                # @options = _.sortBy @options, (o, i) =>
                #   #o.stringifiedRank = @matchHash[o.id] + " Matched Choice:"
                #   if o.ct_order
                #     o.doctorRec = true
                #     1000
                #   else if o.id is @bestTreatment.id
                #     999
                #   else
                #     if @optionHeights[o.id] then @optionHeights[o.id] else 2
                # .reverse()

              @visibleOptions = _.first @options, 3
              d.resolve()
          , (error) =>
            d.reject()
        , (error) =>
          d.reject()

        d.promise

      submitRow: (propertyId) ->
        # find options associated with propertyId
        ops = @dauopsHash[propertyId]
        # if they are all submitted
        if _.filter(ops, (op) -> !op.submitted).length is 0
          heightInfo = DecisionAidUserOptionProperty.calculateTreatmentPercentages(@decisionAidUser, @decisionAid, @userProps, @dauopsHash, @options, @properties)
          @optionHeights = heightInfo.heights
          @bestTreatment = heightInfo.bestTreatment
          @scope.$digest() if !@scope.$$phase

      submitUserOptionProperties: () ->
        finalDauops = []
        _.each @dauopsHash, (dauops) => _.each dauops, (dauop) => finalDauops.push dauop

        DecisionAidUserOptionProperty.updateUserOptionProperties(_.filter(finalDauops, (dauop) => dauop.submitted == true), @decisionAidUser.id)
  
      prevState: () ->
        stateName: "decisionAidPropertiesEnhanced"

  ]
