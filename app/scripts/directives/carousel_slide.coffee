'use strict'

app = angular.module('dcida20App')

app.directive 'carousel', [ '_', '$window', '$timeout', (_, $window, $timeout) ->
  restrict: 'C'
  
  link: (scope, element, attr) ->

    win = angular.element($window)

    scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      win.off 'resize'

    mainElement = jQuery(element)

    getHiddenElementHeight = (ele) ->
      tempId = 'tmp-'+ Math.floor(Math.random()*99999)
      jQuery(ele).clone()
        .css('position','absolute')
        .css('height','auto')
        .css('width',jQuery(ele).parent().width())
        .appendTo(jQuery(ele).parent())
        .css('left','-10000em')
        .addClass(tempId).show()
      h = jQuery('.'+tempId).outerHeight()
      jQuery('.'+tempId).remove()
      return h

    setMaxHeight = () ->
      #jQuery(mainElement.find('.carousel-inner')).height(null)
      heights = _.map jQuery(element).find('.carousel-inner .item'), (item) ->
        getHiddenElementHeight(item)
      jQuery(jQuery(element).find('.carousel-inner')).height(_.max(heights))

    # toggle on/off resize when state changes
    # dont calculate every time since we rely on add/remove from DOM to determine max height, so
    # using a little trick to only calculate after resize finishes
    resizeId = null

    doneResizing = () ->
      setMaxHeight()

    win.on 'resize', () ->
      clearTimeout(resizeId)
      resizeId = setTimeout(doneResizing, 500);

    scope.$on '$stateChangeStart', () =>
      win.off 'resize'

    $timeout () ->
      setMaxHeight()
    , 200

    mainElement.on 'touchstart', (e) ->
      xClick = e.originalEvent.touches[0].pageX
      
      mainElement.one 'touchmove', (e) ->
        xMove = e.originalEvent.touches[0].pageX
        if Math.floor(xClick - xMove) > 5
          mainElement.carousel('next')
        else if Math.floor(xClick - xMove) < -5 
          mainElement.carousel('prev');
    
      mainElement.on 'touchend', (e) ->
        mainElement.off("touchmove");
  ]