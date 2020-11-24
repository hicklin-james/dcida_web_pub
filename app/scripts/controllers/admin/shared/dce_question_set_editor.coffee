'use strict'

module = angular.module('dcida20App')

class DceQuestionSetEditorCtrl
  @$inject: ['$scope', '$uibModalInstance', 'options', 'DceQuestionSet', 'Option', 'Property', '$q', '_']
  constructor: (@$scope, @$uibModalInstance, options, @DceQuestionSet, @Option, @Property, @$q, @_) ->
    $scope.ctrl = @
    @loading = true
    @decisionAidId = options.decisionAidId

    @DceQuestionSet.query {decision_aid_id: @decisionAidId}, (dceQuestionSets) =>
    	@dceQuestionSets = dceQuestionSets
    	@loading = false

  saveAndClose: () ->
    @errors = null
    @DceQuestionSet.updateBulk(@decisionAidId, @dceQuestionSets).then (dceQuestionSets) =>
    	@$uibModalInstance.dismiss('close')
  
  cancel: () ->
    @$uibModalInstance.dismiss('close')

module.controller 'DceQuestionSetEditorCtrl', DceQuestionSetEditorCtrl

