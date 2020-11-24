app = angular.module('dcida20App')

app.directive 'sdScrollBottom', [ '$timeout', ($timeout) ->
  scope:
    scrollContainer: "=saScrollContainer"
    typingInProgress: "=saTypingInProgress"
    rescrollWatch: "=saRescrollWatch"
  link: (scope, element) ->
    rescroll = () =>
      $timeout () =>
        $(element).scrollTop($(element)[0].scrollHeight)

    scope.$watch 'rescrollWatch', (nv) =>
      if nv
        rescroll()
        scope.rescrollWatch = false

    scope.$watchCollection 'scrollContainer', (newValue) =>
      if newValue
        rescroll()

    scope.$watch "typingInProgress", (nv) =>
      if nv
        rescroll()
]