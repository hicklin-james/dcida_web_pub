'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'compile', ['$compile', ($compile) ->
  (scope, element, attrs) ->
    scope.$watch(
      (scope) ->
        scope.$eval(attrs.compile)
      , (value) ->
        if value
          element.html(value && value.toString())
          if attrs.bindHtmlScope
            compileScope = scope.$eval(attrs.bindHtmlScope)
          
          $compile(element.contents())(scope) 
        else
          $compile("")(scope)
      )
]