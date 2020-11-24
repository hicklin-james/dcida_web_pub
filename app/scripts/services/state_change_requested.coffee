angular.module('dcida20App')
  .factory 'StateChangeRequested', [ () ->
    subscribeToStateChange: (scope) ->
      scope.$on 'dcida.newUserRequested', () =>
        scope.ctrl.NavBroadcastService.emitLoadingToRoot(true, scope)
        
  ]