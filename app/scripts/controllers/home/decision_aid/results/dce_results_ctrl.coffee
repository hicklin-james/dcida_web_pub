angular.module('dcida20App')
  .factory 'DceResultsCtrl', ['$q', '$timeout', '_', 'Util', ($q, $timeout, _, Util) ->
    class DceResultsCtrl

      constructor: (@scope, @decisionAid, @decisionAidUser, @options, @properties, @optionProperties, @resultMatchOption) ->
        if @resultMatchOption
          @options = _.sortBy(@options, (o) => @resultMatchOption[o.id]).reverse()
        @sortedProperties = _.sortBy @properties, "property_order"
        @visibleOptions = _.first @options, 3

      setupDceResultMatches: () ->
        d = $q.defer()

        if @resultMatchOption
          @optionMatches = @resultMatchOption
          maxVal = -1
          @maxKey = -1
          _.each @optionMatches, (v, k) =>
            if v > maxVal
              maxVal = v
              @maxKey = k
            else if v is maxVal
              @maxKey = -1

        d.resolve()
        d.promise

      prevState: () ->
        stateName: "decisionAidDce"
        params: 
          current_question_set: @decisionAid.dce_question_set_count

  ]