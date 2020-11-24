'use strict'

app = angular.module('dcida20App')

app.directive 'sdColorPicker', [ '_', (_) ->
  restrict: 'E'
  templateUrl: 'views/directives/color_picker.html'
  replace: true
  scope:
    colorValMap: "=saColorValMap"
    colorModel: "=saColorModel"
  
  link: (scope, element, attr) ->

    c = _.find(scope.colorValMap, (cvm) => cvm.key is scope.colorModel)
    if c
      scope.currentColor = c.value
    else
      scope.currentColor = "white"

    scope.selectColor = (cvm) =>
      scope.colorModel = cvm.key
      scope.currentColor = cvm.value
  ]