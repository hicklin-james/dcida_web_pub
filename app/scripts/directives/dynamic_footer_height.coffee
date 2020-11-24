'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdDynamicFooterHeight', [ '$window', '$timeout', ($window, $timeout) ->
  restrict: 'AE'
  transclude: true
  template: "<ng-transclude></ng-transclude>"
  link: (scope, element, attrs) ->
    footer = jQuery(element)
    win = jQuery($window)
    body = jQuery("body").eq(0)

    setBodyHeight = (nv) ->
      body.css('margin-bottom', nv + 'px')

    scope.$watch((() => 
      element[0].offsetHeight
    ),( (nv, ov) => 
      nh = footer.outerHeight(true)
      if nv isnt ov + 1 and 
         nv isnt ov - 1 and
         nv isnt ov + 2 and 
         nv isnt ov - 2
        setBodyHeight(nh)
    ))

    scope.$on 'dcida.imageLoaded', () =>
      nh = footer.outerHeight(true)
      setBodyHeight(nh)

    win.on 'resize', (e) ->
      nh = footer.outerHeight(true)
      setBodyHeight(nh)

]