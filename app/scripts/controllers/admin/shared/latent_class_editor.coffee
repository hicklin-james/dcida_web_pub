'use strict'

module = angular.module('dcida20App')

class LatentClassEditorCtrl
  @$inject: ['$scope', '$uibModalInstance', 'options', 'LatentClass', 'Option', 'Property', '$q', '_']
  constructor: (@$scope, @$uibModalInstance, options, @LatentClass, @Option, @Property, @$q, @_) ->
    @$scope.ctrl = @
    @loading = true
    @decisionAidId = options.decisionAidId

    p1 = @Option.query({decision_aid_id: @decisionAidId}).$promise

    p2 = @Property.query({decision_aid_id: @decisionAidId}).$promise

    p3 = @LatentClass.query({decision_aid_id: @decisionAidId}).$promise

    promises = [p1, p2, p3]

    @$q.all(promises).then (ps) =>
    	@options = ps[0]
    	@properties = ps[1]
    	@latentClasses = ps[2]
    	@_.each @latentClasses, (lc) =>
      	lc.setup()
      @loading = false

  addLatentClass: () ->
  	latentClass = new @LatentClass()
  	latentClass.initialize(@decisionAidId, @options, @properties)
  	@latentClasses.push latentClass

  deleteLatentClass: (latentClass) ->
  	latentClass._destroy = true
      
  saveAndClose: () ->
    @errors = null
    if !@checkLatentClassProperties()
      @errors = ['Latent class attribute weights by class must add up to 100 in each class']
    else
      @LatentClass.createAndUpdateAndDeleteBulk(@decisionAidId, @latentClasses).then (r) =>
  		  @$uibModalInstance.dismiss('close')
  
  cancel: () ->
  	@$uibModalInstance.dismiss('close')

  checkLatentClassProperties: () ->
    !@_.some @latentClasses, (lc) =>
      sum = 0
      @_.each @properties, (p) =>
        sum += lc.latent_class_properties[p.id].weight
      sum isnt 100


module.controller 'LatentClassEditorCtrl', LatentClassEditorCtrl

