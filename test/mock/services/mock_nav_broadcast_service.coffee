'use strict'

class MockNavBroadcastService
  @$inject: []
  constructor: () ->

  emitLoadingToRoot: (loadingVal, scope) ->
  	scope.ctrl.loading = loadingVal


angular.module('dcida20AppMock').service 'MockNavBroadcastService', MockNavBroadcastService