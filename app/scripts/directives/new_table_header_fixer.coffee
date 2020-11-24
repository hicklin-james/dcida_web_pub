'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdNewTableHeaderFixer', [ '$window', '_', '$compile', '$timeout', '$state', ($window, _, $compile, $timeout, $state) ->
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
    headerColumns = []

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
      maxHeight = 0
      #body.append(headerDiv)
      cbHeight = 0
      _.each headerColumns, (col, i) =>
        #o = scope.options()[i]
        title = jQuery(headers[i]).find(".opt-title").eq(0)
        newEle = "<div style='display: inline-block; text-align: center; width: #{title.width()}px;'></div>"
        header = jQuery(newEle)
        hc = jQuery(angular.copy(headers[i]))
        if scope.bestMatchEnabled
          hc.append("<div ng-if='#{o.id} === bestMatch.id' class='label label-success'>Best Match</div>")
        header.append(hc)
        header.css("position", "absolute")
        header.css("left", jQuery(img).offset().left + (jQuery(img).width() / 2) - (jQuery(title).width() / 2))
        header.css("top", 0)
        header.addClass("fixed-header")

        eleHeight = jQuery(headers[i]).height()
        if eleHeight > maxHeight
          maxHeight = eleHeight

        cb = header.find(".result-checkbox").eq(0)
        jQuery(cb).attr("ng-click", "checkOption(#{i});")
        jQuery(cb).children().eq(0).attr("ng-class", "{'fa-check-square-o text-success': #{o.id} === currentlySelected, 'fa-square-o': #{o.id} !== currentlySelected }")
        cbHeight = cb.height()

        childDiv.append(header)
      headerDiv.height(maxHeight + cbHeight + 5)
      table.append($compile(headerDiv)(scope))

    setFixedHeader = () ->
      offsetTop = element.offset().top # + element.height()
      #images = jQuery(".results-option-image")
      headerDiv = jQuery(".scrollable-results-table-row").eq(0)
      optionPropertyRows = jQuery(".option-property-rows")
      headerColumns = jQuery(headerDiv).find(".table-element")
      upperMargin = if headerDiv then headerDiv.outerHeight(true) else 0
      #offsetTop = offsetTop + (if headerDiv.length > 0 then headerDiv.outerHeight(true) else 0 )
      scrollTop = win.scrollTop()
      offsetTop -= upperMargin if fixedHeadersSet
      #console.log "offset top: " + offsetTop
      #console.log "scroll top: " + scrollTop
      if offsetTop > 0 and scrollTop > 0 and scrollTop >= offsetTop
        if !fixedHeadersSet
          #console.log "here!"
          #buildHeaderDiv(images, headers)
          #headerDiv.find("img").addClass("ninja")
          #$timeout () =>
          headerDiv.addClass("fixed-to-top container")
          optionPropertyRows.css("margin-top", upperMargin)
          fixedHeadersSet = true
      else
        if fixedHeadersSet
          #console.log "must remove!"
          #jQuery('#results-table-fixed-header').remove()
          #headerDiv.find("img").removeClass("ninja")
          #$timeout () =>
          headerDiv.removeClass("fixed-to-top container")
          optionPropertyRows.css("margin-top", 0)
          fixedHeadersSet = false

    #setHeaderHeight()

    win.on 'scroll', (e) ->
      setFixedHeader()

    table.on 'scroll', (e) ->
      horizontalScroll = true
      setFixedHeader()

    win.on 'resize', (e) ->
      resizeHappened = true
      setFixedHeader()
      
]