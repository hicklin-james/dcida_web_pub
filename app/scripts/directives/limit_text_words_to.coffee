'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdLimitTextWordsTo', ['$parse', ($parse) ->
  require: 'ngModel'
  scope:
    validLength: '@saValidLength'
    ngModel: "=ngModel"
  link: (scope, element, attrs) ->

    scope.$watch "ngModel", (nv) ->
      if nv
        checkLength(nv)

    validLength = parseInt(scope.validLength)

    checkLength = (nv) ->
      if nv.length > validLength
        scope.ngModel = nv.substring(0,validLength-1)


]