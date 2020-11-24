'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdFaCheckbox', [ () ->
  restrict: 'E'
  scope:
    model: "=ngModel"
  template: 
    '<i class="fa fa-fw fa-lg clickable" ng-click="toggleModel()" ng-class="{\'fa-square-o\': !model, \'fa-check-square-o text-success\': model}"></i>'
  
  link: (scope, element, attrs) ->

    scope.toggleModel = () ->
      scope.model = !scope.model
]