'use strict'

class NavBroadcastService
  @$inject: []
  constructor: () ->

  emitLoadingToRoot: (loadingVal, scope) ->
    data = 
      loading: loadingVal
      scope: scope
    scope.$emit 'dcida.loadingChanged', data


angular.module('dcida20App').service 'NavBroadcastService', NavBroadcastService