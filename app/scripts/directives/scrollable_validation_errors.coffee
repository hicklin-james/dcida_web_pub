'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdScrollableValidationErrors', ['$document', '_', '$window', '$timeout', ($document, _, $window, $timeout) ->
  scope:
    validationErrors: "=saValidationErrors"
  link: (scope, element, attrs) ->

    findFirstValidationError = () ->
      if scope.validationErrors and !_.isEmpty(scope.validationErrors)
        windowY = $window.scrollY;
        lowestYPos = 450000
        lowestYEle = null
        _.each scope.validationErrors, (val, key) ->
          keyAccess = "#question-id-#{key}"
          eleY = $(keyAccess).offset().top
          if eleY < lowestYPos
            lowestYPos = eleY
            lowestYEle = keyAccess

        $document.scrollTopAnimated(lowestYPos - 10, 1000)
        

    scope.$watch 'validationErrors', (nv, ov) ->
      if nv
        $timeout () =>
          findFirstValidationError()
]