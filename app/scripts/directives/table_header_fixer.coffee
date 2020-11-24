'use strict'

###*
 # @ngdoc overview
 # @name dcida20App.directive:sdTableHeaderFixer
 # @description
 # # sdTableHeaderFixer
 #
 # Use this directive on the results table to fix the header to the top of the page
 # when table scrolling
###

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdTableHeaderFixer', [ '$window', '_', '$compile', '$timeout', '$state', ($window, _, $compile, $timeout, $state) ->
  restrict: 'A'
  scope:
    options: '&saOptions'
    bestMatch: '=saBestMatch'
    selectOptionFunc: '&saSelectOptionFunc'
    currentlySelected: "=saCurrentlySelected"
    bestMatchEnabled: "=saBestMatchEnabled"

  link: (scope, element, attrs) ->
    win = jQuery($window)
    fixedHeadersSet = false
    table = jQuery("#main-results-table-wrapper")
    resizeHappened = false
    horizontalScroll = false

    scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      win.off 'scroll'
      table.off 'scroll'
      win.off 'resize'

    setHeaderHeight = () ->
      headers = jQuery(".results-option-image-cell-div")
      maxHeadHeight = Math.max.apply(null, _.map(headers, (h) -> 
        jQuery(h).outerHeight(true)))
      _.each headers, (h) ->
        jQuery(h).height(maxHeadHeight + 20)

    scope.checkOption = (index) ->
      scope.selectOptionFunc({option: scope.options()[index]})

    buildHeaderDiv = (images, headers) ->
      headerDiv = jQuery("<div id='results-table-fixed-header' style='background-color: white; border-bottom: 1px solid grey; z-index: 20;
                           width: 100%; position: fixed; top: 0; left: 0'><div id='results-table-fixed-header-inner' style='position: relative;'></div></div>")
      childDiv = headerDiv.children().eq(0)
      heights = []

      _.each images, (img, i) =>
        localHeight = 0

        o = scope.options()[i]
        title = jQuery(headers[i]).find(".opt-title").eq(0)
        newEle = "<div style='display: inline-block; text-align: center; width: #{title.width()}px;'></div>"
        header = jQuery(newEle)
        hc = jQuery(angular.copy(headers[i]))
        if scope.bestMatchEnabled and scope.bestMatch.id is o.id
          hc.append("<div class='label label-success'>Best Match</div>")
          localHeight += 35

        header.append(hc)
        header.css("position", "absolute")
        header.css("left", jQuery(img).offset().left + (jQuery(img).width() / 2) - (jQuery(title).width() / 2))
        header.css("top", 0)
        header.addClass("fixed-header")

        localHeight += jQuery(headers[i]).height()

        cb = header.find(".result-checkbox").eq(0)
        jQuery(cb).attr("ng-click", "checkOption(#{i});")
        jQuery(cb).children().eq(0).attr("ng-class", "{'fa-check-square-o text-success': #{o.id} === currentlySelected, 'fa-square-o': #{o.id} !== currentlySelected }")
        localHeight += cb.height()
        localHeight += 5
        heights.push localHeight

        childDiv.append(header)
      headerDiv.height(_.max(heights))
      table.append($compile(headerDiv)(scope))

    setFixedHeader = () ->
      offsetTop = element.offset().top # + element.height()
      images = jQuery(".results-option-image")
      headers = jQuery(".opt-title-wrapper")
      offsetTop = offsetTop + images.eq(0).outerHeight()
      scrollTop = win.scrollTop()
      if offsetTop > 0 and scrollTop > 0 and scrollTop >= offsetTop
        if !fixedHeadersSet
          buildHeaderDiv(images, headers)
          fixedHeadersSet = true
        else if resizeHappened
          jQuery('#results-table-fixed-header').remove()
          buildHeaderDiv(images, headers)
          resizeHappened = false
        else if horizontalScroll
          jQuery('#results-table-fixed-header').remove()
          buildHeaderDiv(images, headers)
          horizontalScroll = false
      else
        jQuery('#results-table-fixed-header').remove()
        fixedHeadersSet = false

    win.on 'scroll', (e) ->
      if jQuery($window).width() >= 992
        setFixedHeader()
      else
        jQuery('#results-table-fixed-header').remove()

    table.on 'scroll', (e) ->
      horizontalScroll = true
      if jQuery($window).width() >= 992
        setFixedHeader()
      else
        jQuery('#results-table-fixed-header').remove()

    win.on 'resize', (e) ->
      resizeHappened = true
      if jQuery($window).width() >= 992
        setFixedHeader()
      else
        jQuery('#results-table-fixed-header').remove()
]