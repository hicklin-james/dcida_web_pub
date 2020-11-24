'use strict'

app = angular.module('dcida20App')

app.directive 'sdFixedHeader', [ '$window', '$compile', '$document', '_', '$rootScope', ($window, $compile, $document, _, $rootScope) ->
  restrict: 'A'
  scope:
    hideAtWidth: '@saHideAtWidth'
  link: (scope, element, attrs) ->
    win = jQuery($window)

    $rootScope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      jQuery('#fixed-table-header').remove()
      win.off 'scroll'
      win.off 'resize'

    elem = jQuery(element[0])
    headerEle = jQuery(elem.find('thead'))
    headerElements = headerEle.find('th')
    body = jQuery($document[0].body)
    minWidth = parseInt(scope.hideAtWidth)
    stickyElementCreated = false

    createStickyElement = () ->
      headerDiv = jQuery("<div id='fixed-table-header' style='position: fixed; top: 0; left: 0; width: 100%; background: white; border-bottom: 1px solid #ddd;'></div>")
      headerDiv.height(headerEle.outerHeight(true))

      _.each headerElements, (ele) ->
        jele = jQuery(ele)
        newDiv = jQuery("<div style='padding: 8px; position: absolute; text-align: center; font-weight: bold; bottom: 0;'></div>")
        newDiv.width(jele.outerWidth(true))
        #newDiv.height(jele.outerHeight(true))
        newDiv.css('left', jele.position().left)
        newDiv.css('line-height', jele.css('line-height'))
        newDiv.text(jele.text())
        headerDiv.append(newDiv)

      body.append($compile(headerDiv)(scope))

    checkStickElementRequired = () ->
      return false if win.outerWidth() <= minWidth
      offsetTop = element.offset().top 
      scrollTop = win.scrollTop()
      eleHeight = element.outerHeight()
      return scrollTop > offsetTop && scrollTop <= (offsetTop + eleHeight - headerEle.outerHeight())

    doAll = () ->
      req = checkStickElementRequired()
      if req
        if !stickyElementCreated
          createStickyElement()
          stickyElementCreated = true
      else
        jQuery('#fixed-table-header').remove()
        stickyElementCreated = false

    win.on 'scroll', () ->
      doAll()

    win.on 'resize', (e) ->
      jQuery('#fixed-table-header').remove()
      stickyElementCreated = false
      doAll()

    doAll()
]