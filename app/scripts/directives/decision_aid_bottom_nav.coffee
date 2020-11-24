'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdBottomNav', [ () ->
  restrict: 'E'
  scope:
    showNext: "@saShowNext"
    nextSubmit: "&saNextSubmit"
    enableNext: "=?saEnableNext"
    shouldHideNext: "=saShouldHideNext"
    showPrev: "@saShowPrev"
    prevLink: "&saPrevLink"
    shouldHidePrev: "=saShouldHidePrev"
    centerNav: "@saCenterNav"
  templateUrl: "views/directives/decision_aid_bottom_nav.html"
  
  link: (scope, element, attrs) ->
    if !attrs.saEnableNext
      scope.enableNext = true
]