'use strict'

class MockStateService
  @$inject: ['$q']
  constructor: ($q) ->

  go: (target, params) ->
    @target = target
    @params = params

angular.module('dcida20AppMock').service 'MockStateService', MockStateService