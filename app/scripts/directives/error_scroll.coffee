'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdErrorScroll', ['$document', ($document) ->
  scope:
    errors: "=saErrors"
    scrollModal: "@saScrollModal"
  template:
    "<div role='alert' class='alert alert-danger' ng-show='errors'>
        <p ng-repeat='error in errors'>
          {{$index + 1}}. {{error}}
        </p>
      </div>"
  link: (scope, element, attrs) ->
    scope.$watch 'errors', (nv, ov) ->
      if nv
        if scope.scrollModal
          $(".modal.in").scrollTopAnimated(0, 500)
        else
          $document.scrollTopAnimated(0, 500)
]