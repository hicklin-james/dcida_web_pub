'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdShouldShow', [ '_', (_) ->
  restrict: 'E'
  transclude: true
  scope:
    item: "@saItem"
    attrs: "@saAttrs"
  template:
    '<div ng-if="show" ng-transclude>
    </div>'
  link: (scope, element, attrs) ->
    split_attrs = scope.attrs.split(",")
    scope.show = _.all split_attrs, (attr) -> scope.item[attr]

]