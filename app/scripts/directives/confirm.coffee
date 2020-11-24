'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdConfirm', ['Confirm', (Confirm) ->
  scope:
    message: "@saMessage"
    header: "@saHeader"
    size: "@saSize"
  link: (scope, element, attrs) ->
    if !scope.size
      scope.size = "md-lg"

    showConfirm = () =>
      Confirm.frontendInfo(
        header: scope.header
        messageSub: scope.message
        size: scope.size
      )

    element.on('click', showConfirm)
]