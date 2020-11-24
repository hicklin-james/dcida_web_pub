'use strict'

app = angular.module('dcida20App')

# shows a well with additional information that can be expanded
app.directive 'sdInformation', ['$document', ($document) ->
  restrict: 'E',
  transclude: true,
  scope:
    infoColor: "@saInfoColor"
  template:
    '<div class="half-space-bottom">
      <i class="fa fa-lg fa-info-circle" ng-class="infoColor"></i>
      <span ng-transclude></span>
    </div>'  
  link: (scope, element, attrs) =>
    if !attrs.saInfoColor
      scope.infoColor = "dcida-info-icon"
]