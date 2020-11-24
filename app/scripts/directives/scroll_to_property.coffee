'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdScrollToProperty', [ '_', '$document', (_, $document) ->
  scope: false
  link: (scope, element, attrs) ->

    scope.ctrl.dirSetUserProperty = (prop, value, index) ->
      if !scope.ctrl.propertiesHash[prop.id] && angular.element(element).find(".mobile-indicator").is(":visible")
        # only do the automatic scrolling on mobile
        laterProps = scope.ctrl.properties.slice(index+1, scope.ctrl.properties.length)
        nextUnansweredPropIndex = _.findIndex laterProps, (p) =>
          !scope.ctrl.propertiesHash[p.id]?

        if nextUnansweredPropIndex >= 0
          scrollIndex = nextUnansweredPropIndex + index + 1
          ne = angular.element('#decide-prop-' + scrollIndex)
          selectionHeight = ne.find(".response-button-td").eq(0).outerHeight() * 5
          $document.scrollTo ne, selectionHeight, 1000

      scope.ctrl.setUserProperty(prop, value)
]