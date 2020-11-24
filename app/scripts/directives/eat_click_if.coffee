'use strict'
# credit goes to http://stackoverflow.com/questions/25600071/how-to-achieve-that-ui-sref-be-conditionally-executed

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'eatClickIf', [
  '$parse'
  '$rootScope'
  ($parse, $rootScope) ->
    {
      priority: 100
      restrict: 'A'
      compile: ($element, attr) ->
        fn = $parse(attr.eatClickIf)
        {
          pre: (scope, element) ->
            eventName = 'click'
            element.on eventName, (event) ->

              callback = ->
                if fn(scope, $event: event)
                  # prevents ng-click to be executed
                  event.stopImmediatePropagation()
                  # prevents href 
                  event.preventDefault()
                  return false
                return

              if $rootScope.$$phase
                scope.$evalAsync callback
              else
                scope.$apply callback
              return
            return
          post: ->

        }

    }
]