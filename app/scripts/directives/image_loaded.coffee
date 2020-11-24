'use strict'

app = angular.module('dcida20App')

# shows a well with additional information that can be expanded
app.directive 'sdImageLoaded', [ '$rootScope', ($rootScope) ->
  restrict: 'A'
  link: (scope, element, attrs) =>
    element.bind 'load', () =>
      $rootScope.$broadcast 'dcida.imageLoaded'

    element.bind 'error', () =>
      $rootScope.$broadcast 'dcida.imageLoaded'
]