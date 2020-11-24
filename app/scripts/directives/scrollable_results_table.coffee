'use strict'

app = angular.module('dcida20App')

app.directive 'sdScrollableResultsTable', ['$timeout', '_', ($timeout, _) ->
  restrict: 'E'
  templateUrl: 'views/directives/scrollable_results_table.html'
  controller: ScrollableResultsTableCtrl
  scope:
    options: "=saOptions"
    properties: "=saProperties"
    optionProperties: "=saOptionProperties"
    optionHeights: "=saOptionHeights"
    bestTreatment: "=saBestTreatment"
    percentagesEnabled: "=saPercentagesEnabled"
    bestMatchEnabled: "=saBestMatchEnabled"
    selectedOptionId: "=saSelectedOptionId"
  link: ($scope, $element, $attrs) ->

    # watching the height seems to be the only reliable way to make sure the
    # table properly renders. Since this is computation-heavy, I am giving 5
    # seconds to fully render the table before unbinding these watchers, since
    # they aren't needed if I am responding to window-resize events too.
    #
    # NOTE: The $watch() method returns an unbind function
    $timeout () =>
      unbindWatchers = []
      _.each jQuery(".inner-table-element, .row-headers-content"), (ele) =>
        unbindWatchers.push($scope.$watch () =>
          jQuery(ele).outerHeight(true)
        , (nv, ov) =>
          $scope.ctrl.findMaxRowHeights()
        , true)

      $timeout () =>
        _.each unbindWatchers, (fn) =>
          fn()
      , 5000
    
]

class ScrollableResultsTableCtrl
  @$inject: ['$scope', '_', '$timeout', '$window', '$element', '$uibModal']
  constructor: (@$scope, @_, @$timeout, @$window, @$element, @$uibModal) ->
    @$scope.ctrl = @

    @globalIndex = 0
    @options = @$scope.options
    @hasImages = false
    @_.each @options, (o, ind) =>
      o.currIndex = ind
      if !@hasImages and o.original_image_url
        @hasImages = true

    @properties = @$scope.properties
    @optionProperties = @$scope.optionProperties
    @optionHeights = @$scope.optionHeights
    @bestTreatment = @$scope.bestTreatment
    @percentagesEnabled = @$scope.percentagesEnabled
    @bestMatchEnabled = @$scope.bestMatchEnabled
    @selectedOptionId = @$scope.selectedOptionId

    #console.log @optionProperties
    @_.each @properties, (p) =>
      if @_.all(@optionProperties[p.id], (op) => op.injected_information_published)
        p.show_more_info = true

    win = jQuery(@$window)
    @calcMaxOnScreen()
    #@findMaxRowHeights()

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      win.off 'resize'

    @$scope.$on 'dcida.imageLoaded', () =>
      @findMaxRowHeights()
      if !@$scope.$$phase
        @$scope.$apply()

    resizeId = null
    doneResizing = () =>
      @calcMaxOnScreen()
      @findMaxRowHeights()
      if !@$scope.$$phase
        @$scope.$apply()

    win.on 'resize', () =>
      clearTimeout(resizeId);
      resizeId = setTimeout(doneResizing, 250)

  selectOption: (id) ->
    @selectedOptionId = id
    @$scope.selectedOptionId = id

  calcMaxOnScreen: () ->
    @maxOnScreen = 0
    if @$window.innerWidth > 991
      @maxOnScreen = 3
    else if @$window.innerWidth > 767
      @maxOnScreen = 2
    else
      @maxOnScreen = 1

  findMaxRowHeights: () ->
    if jQuery(".inner-table-element, .row-headers-content").length > 0
      @maxRowHeights = []
      rows = jQuery(".scrollable-results-table-row")
      @_.each rows, (row, index) =>
        maxEle = @_.max(jQuery(row).find(".inner-table-element, .row-headers-content"), (ele) =>
          jQuery(ele).outerHeight(true)
        )
        @maxRowHeights[index] = jQuery(maxEle).outerHeight(true)
    else
      @maxRowHeights = []

  moreInfo: (property) ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/decision_aid/_results_more_info.html"
      controller: "ResultsMoreInfoCtrl"
      size: 'lg'
      resolve:
        options: () =>
          property: property
          options: @options
          optionProperties: @_.toArray(@optionProperties[property.id])
    )

  goRight: () ->
    @calcMaxOnScreen()

    if @globalIndex < @options.length - @maxOnScreen
      @globalIndex++
      @_.each @options, (item) =>
        item.currIndex--

  goLeft: () ->
    @calcMaxOnScreen()

    if @globalIndex > 0
      @globalIndex--
      @_.each @options, (item) =>
        item.currIndex++
 