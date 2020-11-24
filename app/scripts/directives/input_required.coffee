'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'inputRequired', [() ->
  transclude: true
  template: '<ng-transclude></ng-transclude><sup class="text-danger">*</sup>'
]