'use strict'

module = angular.module('dcida20App')

class MyOptionsPreviewCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'options', '$uibModalInstance', 'Option', '$q']
  constructor: (@$scope, @$state, @$location, @Auth, options, @$uibModalInstance, @Option, @$q) ->
    @$scope.ctrl = @
    
    fullDa = options.decisionAid

    @$q.all([fullDa.preview(), @Option.preview(fullDa.id)]).then (prs) =>

      @decisionAid  = prs[0]
      @options      = prs[1]
      @value        = options.value
      @subDecisions = options.subDecisions

      window.alert(
        "Decision Aid ID: "         + options.id +
        "// Decision Aid title: "   + options.title +
        "// subDecisions: "         + options.subDecisions +    #array of subDecisions
        "// n:    "                 + options.value +
        "// @options: "             + @options[0].decision_aid_id+
        "// @subDecisions[0]: "        + @subDecisions[0].decisionAidId +
        "// @subDecisions[1]: "        + @subDecisions[1].decision_aid_id
        )
    
  close: () ->
    @$uibModalInstance.close()

module.controller 'MyOptionsPreviewCtrl', MyOptionsPreviewCtrl