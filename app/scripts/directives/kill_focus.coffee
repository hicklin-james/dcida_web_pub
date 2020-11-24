'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdKillFocus', [() ->
  scope: true
  link: (scope, element, attrs) ->
    scope.$on "killElementFocus", (nv) ->
      console.log "Killing focus!"
      killFocus()

    killFocus = () ->
      element.blur()

]