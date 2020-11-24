'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'formGroupNotUsed', ['$document', ($document) ->
  transclude: true,
  scope: true,
  restrict: "C",
  template: '<div ng-transclude ng-click="focusElement($event)"></div>',
  link: (scope, element, attrs) ->

    scope.focusElement = (event) ->
      inp = angular.element(element).find("input")
      inp.focus()
      event.preventDefault()


]