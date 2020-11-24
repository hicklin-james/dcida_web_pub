'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdAnimatedEllipsis', [ '$timeout', ($timeout) ->
  restrict: 'E'
  template:  "<span><span ng-show='counter >= 1'>.</span><span ng-show='counter >= 2'>.</span><span ng-show='counter >= 3'>.</span></span>"
  
  link: (scope, element, attrs) ->
    scope.counter = 1

    setCounter = () =>
      if scope.counter < 4
        scope.counter += 1
      else
        scope.counter = 1

      $timeout () =>
        setCounter()
      , 200

    $timeout () =>
      setCounter()
    , 200
]