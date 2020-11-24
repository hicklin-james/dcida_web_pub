'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdInnerNav', ['$document', '$window', '$timeout', '_', ($document, $window, $timeout, _) ->
  scope:
    items: "=saItems"
    currentItem: "=saCurrentItem"
    itemClick: "&saItemClick"
  templateUrl: "views/directives/inner_nav.html"
  link: (scope, element, attrs) ->

    scope.percentCompleted = () ->
      return 0 if !scope.items
      completedItems = _.filter scope.items, (i) -> i.complete

      pc = (completedItems.length / scope.items.length ) * 100
      pc

]