'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdAnimatedIconArray', ['$document', '$window', '$timeout', '_', 'Util', '$sce', 'IconArrayUtil', ($document, $window, $timeout, _, Util, $sce, IconArrayUtil) ->
  scope: true
  template:"<div id='{{chartid}}-wrapper' class='animated-icon-array-chart' style='width: 100%; height: 100%;'>
              <svg viewBox='0 0 1000 310' preserveAspectRatio='xMidYMid meet' style='width: 100%;' id='{{chartid}}'></svg>
              <div class='pull-right'>
                <button class='btn btn-primary' ng-click='play()'>Play <i class='fa fa-redo-alt fa-fw'></i></button>
              </div>
            </div>"
  compile: ($element, attr) ->    
      pre: (scope, element) ->
        scope.chartid = Util.makeId()

      post: (scope, element, attrs) ->
        # define all vars that need to stay in scope
        autoTransitioning = false
        win = jQuery($window)
        itemsPerRow = 25 # should be from scope
        testData = undefined # should be from scope
        otherTestData = undefined # should be from scope
        transitionDataPoints = [
          { val: true }
          { val: false }
          { val: false }
          { val: false }
        ]
        initialRectHeight = undefined
        viewboxHeight = undefined

        # constants
        chartWidth = 1000
        boxWidth = 370
        xPadding = 10
        yPadding = 10
        transitionSpeed = 1000
        radiusPadding = 2
        personPadding = 3
        transitionCircleXPadding = 400
        transitionCircleYPadding = 5
        transitionCircleRadius = 20
        usableTransitionCircleWidth = chartWidth - (2 * transitionCircleXPadding)
        allCirclesWidth = chartWidth - boxWidth - (2 * xPadding)
        singleCircleWidth = allCirclesWidth / itemsPerRow
        circleRadius = singleCircleWidth / 2 - radiusPadding
        headRadius = singleCircleWidth / 3.5
        textPadding = 20
        viewboxWidth = 1000

        # containers
        svg = undefined
        postAnimationTextWrapper = undefined
        postAnimationTexts = undefined
        initialText = undefined
        postAnimationArrowWrapper = undefined
        postAnimationArrows = undefined
        otherTextsWrapper = undefined
        otherTexts = undefined
        otherArrows = undefined
        outerWrap = undefined
        outerWrap = undefined
        rectLabelWrapper = undefined
        rectWrapper = undefined
        transitionButtonWrapper = undefined
        rects = undefined
        rectLabelRects = undefined
        initialText = undefined
        transitionButtons = undefined
        people = undefined

        scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
          win.off 'resize'

        endall = (transition, callback) ->
          if typeof callback isnt "function" then throw new Error("Wrong callback in endall")
          if transition.size() is 0 then callback()
          n = 0
          transition 
            .each(() => ++n ) 
            .each("end", ()  => if !--n then callback.apply(this, arguments))

        setupTestData = () ->
          testData = [
            {
              val: 13
              color: '#82D78C'
              text: '13 people would significantly improve'
            }
            {
              val: 17
              color: '#008c78'
              text: '17 people would somewhat improve'
            }
            {
              val: 28
              color: '#CD913C'
              text: '28 people would stay the same'
            }
            {
              val: 27
              color: '#DE2D26'
              text: '27 people would somewhat worsen'
            }
            {
              val: 15
              color: '#A50F15'
              text: '15 people would significantly worsen'
            }
          ]
          otherTestData = new Array(100)
          summed = 0
          testDataI = 0
          localI = 0
          i = 0
          while i < otherTestData.length
            numRowsSummer = 0
            if localI >= testData[testDataI].val
              numRowsSummer += Math.ceil(testData[testDataI].val / itemsPerRow)
              summed += testData[testDataI].val
              testDataI++
              localI = 0
            otherTestData[i] =
              i: i
              localI: localI
              bucket: testDataI
              maxDataVal: testData[testDataI].val
              color: testData[testDataI].color
              numRowsRequired: if otherTestData[i - 1] then numRowsSummer + otherTestData[i - 1].numRowsRequired else 0
            localI++
            i++

        setupChart = () ->
          svg = d3.select('#' + scope.chartid)
          setupTestData()

          outerWrap = svg.append('g')
          rectLabelWrapper = outerWrap.append('g')
          rectWrapper = outerWrap.append('g')
          transitionButtonWrapper = outerWrap.append('g')
          thecol = Math.ceil(otherTestData.length / itemsPerRow)
          rowHeight = headRadius + thecol * (6.9 * headRadius + 2.0 * personPadding)
          initialRectHeight = rowHeight + 2 * yPadding
          rects = rectWrapper.selectAll('rect').data(testData).enter().append('rect').attr('x', boxWidth).attr('y', 0).attr('stroke', 'white').attr('stroke-width', '1').attr('width', chartWidth - boxWidth).attr('height', (d, i) ->
            initialRectHeight
          ).attr('fill', 'white')
          rectLabelRects = rectLabelWrapper.selectAll('rect').data(testData).enter().append('rect').attr('x', xPadding).attr('stroke', 'darkblue').attr('stroke-width', 1).attr('width', boxWidth - (4 * xPadding)).attr('fill', 'white')
          initialText = rectLabelWrapper.append('text').attr('x', xPadding * 2).attr('y', 4.5 * yPadding).attr('dy', 0).attr('fill', 'black').attr('font-size', '15px').attr('font-family', 'Arial').attr('class', 'fill-transparent')
          transitionButtons = transitionButtonWrapper.selectAll('circle').data(transitionDataPoints).enter().append('circle').attr('cx', (datum, index) ->
            halfWidth = usableTransitionCircleWidth / transitionDataPoints.length / 2
            transitionCircleXPadding + usableTransitionCircleWidth / transitionDataPoints.length * index + halfWidth
          ).attr('r', transitionCircleRadius).attr('class', 'clickable transition-circle')
          totalWidth = svg.node().getBoundingClientRect().width
          rectHeight = rectWrapper.node().getBoundingClientRect().height
          transitionButtonsHeight = transitionButtonWrapper.node().getBoundingClientRect().height + 2 * transitionCircleYPadding
          scalingFactor = totalWidth / (rectHeight + transitionButtonsHeight)
          people = outerWrap.append('g').selectAll('g').data(otherTestData).enter().append('g')
          people.append 'circle'
          people.append 'path'
          viewboxHeight = viewboxWidth / scalingFactor

        $timeout () =>
          setupChart()

          transitionToStage1 = (animate) ->
            initialText.attr 'class', 'fill-transparent'
            if animate
              if postAnimationTexts
                postAnimationTexts.attr 'class', 'fill-transparent'
              if postAnimationArrows
                postAnimationArrows.attr 'class', 'fill-transparent'
              if otherTextsWrapper
                otherTexts.attr 'class', 'fill-transparent'
                otherArrows.attr 'class', 'fill-transparent'

              rectLabelWrapper.selectAll('rect').transition().duration(transitionSpeed).attr('y', 2 * yPadding)
              transitionButtons.transition().duration(transitionSpeed).attr('cy', initialRectHeight + transitionCircleYPadding + transitionCircleRadius).attr 'fill', (datum) ->
                if datum.val then '#7cd5ff' else 'lightgrey'
              people.each (d, i) ->
                me = d3.select(this)
                IconArrayUtil.drawPerson(headRadius * 3, me, '#CD913C', true, transitionSpeed)
                return
              people.transition().duration(transitionSpeed).attr('transform', (d, i) ->
                col = 2
                row = 0.2
                xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
                yPosWithinDrawableSpace = yPadding + headRadius + row * (7.0 * headRadius + 2 * personPadding)
                'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
              ).call endall, ->
                if postAnimationTexts
                  postAnimationTextWrapper.remove()
                if postAnimationArrows
                  postAnimationArrowWrapper.remove()
                if otherTextsWrapper
                  otherTexts.attr 'class', 'fill-transparent'
                  otherArrows.attr 'class', 'fill-transparent'
                initialText.attr('class', 'fill-black')
                  .text('This is you.')
                  .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2)
                rectLabelRects.transition().duration(transitionSpeed/2)
                  .attr("height", initialText.node().getBBox().height + textPadding)
                return
              people.selectAll('circle').transition().duration(transitionSpeed).attr('fill', '#CD913C').attr 'stroke', '#CD913C'
              people.selectAll('path').transition().duration(transitionSpeed).attr('fill', '#CD913C').attr 'stroke', '#CD913C'
              computedHeight = viewboxHeight / viewboxWidth * svg.node().getBoundingClientRect().width
              svg.transition().duration(transitionSpeed).attr('viewBox', '0 0 ' + viewboxWidth + ' ' + viewboxHeight).style 'height', computedHeight + 'px'
              rects.transition().duration(transitionSpeed)
                .attr('height', initialText.node().getBBox().height+textPadding)
                .attr('y', 2 * yPadding)
            else
              rectLabelWrapper.selectAll('rect').attr('y', 2 * yPadding)
              transitionButtons.attr('cy', initialRectHeight + transitionCircleYPadding + transitionCircleRadius).attr 'fill', (datum) ->
                if datum.val then '#7cd5ff' else 'lightgrey'
              people.each (d, i) ->
                me = d3.select(this)
                IconArrayUtil.drawPerson(headRadius * 3, me, '#CD913C', false)
                return
              people.attr 'transform', (d, i) ->
                col = 2
                row = 0.2
                xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
                yPosWithinDrawableSpace = yPadding + headRadius + row * (7.0 * headRadius + 2 * personPadding)
                'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
              initialText.attr('class', 'fill-black').text('This is you.').call IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2
              rectLabelRects
                .attr("height", initialText.node().getBBox().height + textPadding)
                .attr('y', 2 * yPadding)
              if postAnimationTexts
                postAnimationTextWrapper.remove()
              if postAnimationArrows
                postAnimationArrowWrapper.remove()
              if otherTextsWrapper
                otherTextsWrapper.remove()
              computedHeight = viewboxHeight / viewboxWidth * svg.node().getBoundingClientRect().width
              svg.attr('viewBox', '0 0 ' + viewboxWidth + ' ' + viewboxHeight).style 'height', computedHeight + 'px'
            return

          transitionToStage2 = ->
            initialText.attr 'class', 'fill-transparent'
            if postAnimationTexts
              postAnimationTexts.attr 'class', 'fill-transparent'
            if postAnimationArrows
              postAnimationArrows.attr 'class', 'fill-transparent'
            if otherTextsWrapper
              otherTexts.attr 'class', 'fill-transparent'
              otherArrows.attr 'class', 'fill-transparent'
            rectLabelWrapper.selectAll('rect').transition().duration(transitionSpeed).attr('y', 2 * yPadding)
            transitionButtons.transition().duration(transitionSpeed).attr('cy', initialRectHeight + transitionCircleYPadding + transitionCircleRadius).attr 'fill', (datum) ->
              if datum.val then '#7cd5ff' else 'lightgrey'
            people.each (d, i) ->
              me = d3.select(this)
              IconArrayUtil.drawPerson(headRadius, me, '#CD913C', true, transitionSpeed)
              return
            people.transition().duration(transitionSpeed).attr('transform', (d, i) ->
              col = i % itemsPerRow
              row = Math.floor(i / itemsPerRow)
              xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
              yPosWithinDrawableSpace = yPadding + headRadius + row * (7.0 * headRadius + 2 * personPadding)
              'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
            
            rects.transition().duration(transitionSpeed)
              .attr('height', initialText.node().getBBox().height+textPadding)
              .attr('y', 2 * yPadding)

            ).call endall, ->
              if postAnimationTexts
                postAnimationTextWrapper.remove()
              if postAnimationArrows
                postAnimationArrowWrapper.remove()
              if otherTextsWrapper
                otherTextsWrapper.remove()
              initialText.attr('class', 'fill-black').text('Imagine there are 100 people like you. If all 100 people had treatment, this is what would happen.').call IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2
              rectLabelWrapper.selectAll('rect').transition().duration(transitionSpeed/2).attr("height", initialText.node().getBBox().height+textPadding)
              return
            people.selectAll('circle').transition().duration(transitionSpeed).attr('fill', '#CD913C').attr 'stroke', '#CD913C'
            people.selectAll('path').transition().duration(transitionSpeed).attr('fill', '#CD913C').attr 'stroke', '#CD913C'
            computedHeight = viewboxHeight / viewboxWidth * svg.node().getBoundingClientRect().width
            svg.transition().duration(transitionSpeed).attr('viewBox', '0 0 ' + viewboxWidth + ' ' + viewboxHeight).style 'height', computedHeight + 'px'
            return

          transitionToStage3 = ->
            #simulateButtonWrapper.remove();
            initialText.attr 'class', 'fill-transparent'
            if otherTextsWrapper
              otherTexts.attr 'class', 'fill-transparent'
              otherArrows.attr 'class', 'fill-transparent'
            #simulateButton.attr('class', 'fill-transparent');
            #simulateButtonText.attr('class', 'fill-transparent');
            summedHeights = 0
            rects.transition().duration(transitionSpeed).attr('height', (datum) ->
              col = Math.ceil(datum.val / itemsPerRow)
              newHeight = col * (7.0 * headRadius + 2.0 * personPadding) + 2 * yPadding
              #var newHeight = (Math.ceil(datum.val / itemsPerRow) * rowHeight) + (2 * yPadding);
              summedHeights += newHeight
              newHeight
            ).attr 'y', (datum, ind) ->
              circleEle = otherTestData.filter((ele) ->
                ele.bucket == ind
              )[0]
              yBase = circleEle.numRowsRequired * (7.0 * headRadius + 2 * personPadding) + circleEle.bucket * 2 * yPadding
              yBase
            postAnimationArrowWrapper = outerWrap.append('g')
            postAnimationArrows = postAnimationArrowWrapper.selectAll('path').data(testData).enter().append('path').attr('d', (datum, ind) ->
              circleEle = otherTestData.filter((ele) ->
                ele.bucket == ind
              )[0]
              eleHeight = (headRadius + 7.0 * headRadius + 2 * personPadding) / 3 * 2
              col = Math.ceil(datum.val / itemsPerRow)
              newHeight = col * (7.0 * headRadius + 2.0 * personPadding) + 2 * yPadding
              yBase = circleEle.numRowsRequired * (7.0 * headRadius + 2 * personPadding) + circleEle.bucket * 2 * yPadding
              #console.log(circleEle)
              yBase = yBase + 3 + newHeight / 2 - (eleHeight / 2)
              path = ''
              if ind == 0
                path = IconArrayUtil.drawArrow('up', 30, 3 * xPadding + boxWidth - 40, yBase + 42)
              else if ind == 1
                path = IconArrayUtil.drawArrow('up', 15, 3 * xPadding + boxWidth - 40, yBase + 34)
              else if ind == 2
                path = IconArrayUtil.drawArrow('right', 15, 3 * xPadding + boxWidth - 40 - 7.5, yBase + 18)
              else if ind == 3
                path = IconArrayUtil.drawArrow('down', 15, 3 * xPadding + boxWidth - 40, yBase + 8)
              else if ind == 4
                path = IconArrayUtil.drawArrow('down', 30, 3 * xPadding + boxWidth - 40, yBase)
              path
            ).attr('fill-opacity', 0).attr('stroke-width', 0)
            .attr('fill', 'black')
            postAnimationTextWrapper = outerWrap.append('g')
            postAnimationTexts = postAnimationTextWrapper.selectAll('text').data(testData).enter().append('text').text((datum) ->
              datum.text
            ).attr('x', 3 * xPadding + boxWidth - 70).attr('y', (datum, ind) ->
              circleEle = otherTestData.filter((ele) ->
                ele.bucket == ind
              )[0]
              eleHeight = (headRadius + 7.0 * headRadius + 2 * personPadding) / 3 * 2
              col = Math.ceil(datum.val / itemsPerRow)
              newHeight = col * (7.0 * headRadius + 2.0 * personPadding) + 2 * yPadding
              yBase = circleEle.numRowsRequired * (7.0 * headRadius + 2 * personPadding) + circleEle.bucket * 2 * yPadding
              #console.log(circleEle)
              yBase = yBase + 3 + newHeight / 2 - (eleHeight / 2)
              textboxHeight = (headRadius + 7.0 * headRadius + 2 * personPadding) / 3 * 2
              yMid = yBase + textboxHeight / 2
              yMid
            ).attr('text-anchor', 'end').attr('dominant-baseline', 'middle').attr('fill', 'transparent').attr('font-size', '15px').attr('font-weight', 'bold').attr('font-family', 'arial').attr('pointer-events', 'none')
            
            rectLabelRects.transition().duration(transitionSpeed).attr('height', (datum) ->
              # var col = Math.ceil(datum.val / itemsPerRow);
              # var newHeight = (col*(7.0*headRadius+(2.0*personPadding))) + (2*yPadding);
              # //var newHeight = (Math.ceil(datum.val / itemsPerRow) * rowHeight) + (2 * yPadding);
              # summedHeights += newHeight;
              (headRadius + 7.0 * headRadius + 2 * personPadding) / 3 * 2
              #newHeight;
            ).attr('y', (datum, ind) ->
              circleEle = otherTestData.filter((ele) ->
                ele.bucket == ind
              )[0]
              eleHeight = (headRadius + 7.0 * headRadius + 2 * personPadding) / 3 * 2
              col = Math.ceil(datum.val / itemsPerRow)
              newHeight = col * (7.0 * headRadius + 2.0 * personPadding) + 2 * yPadding
              yBase = circleEle.numRowsRequired * (7.0 * headRadius + 2 * personPadding) + circleEle.bucket * 2 * yPadding
              #console.log(circleEle)
              return yBase + 3 + newHeight / 2 - (eleHeight / 2)
            ).call endall, ->
              #simulateButtonWrapper.remove();
              #initialText.remove();
              postAnimationTexts.attr 'class', 'fill-black'
              postAnimationArrows.transition().duration(1000).attr('fill', (datum, ind) ->
                circleEle = otherTestData.filter((ele) ->
                  ele.bucket == ind
                )[0]
                circleEle.color
              ).attr('fill-opacity', 1)

              if otherTextsWrapper
                otherTextsWrapper.remove()
              return
            people.each (d, i) ->
              me = d3.select(this)
              IconArrayUtil.drawPerson(headRadius, me, '#CD913C', true, transitionSpeed)
              return
            people.transition().duration(transitionSpeed).attr 'transform', (datum, i) ->
              yBase = datum.numRowsRequired * (7.0 * headRadius + 2 * personPadding) + datum.bucket * 2 * yPadding
              col = datum.localI % itemsPerRow
              row = Math.floor(datum.localI / itemsPerRow)
              xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
              yPosWithinDrawableSpace = yPadding + headRadius + row * (7.0 * headRadius + 2 * personPadding)
              'translate(' + xPosWithinDrawableSpace + ', ' + (yBase + yPosWithinDrawableSpace) + ')'
            people.selectAll('circle').transition().duration(transitionSpeed).attr('fill', (datum) ->
              datum.color
            ).attr 'stroke', (datum) ->
              datum.color
            people.selectAll('path').transition().duration(transitionSpeed).attr('fill', (datum) ->
              datum.color
            ).attr 'stroke', (datum) ->
              datum.color
            transitionButtons.transition().duration(transitionSpeed).attr('cy', ->
              summedHeights + transitionCircleYPadding + transitionCircleRadius
            ).attr 'fill', (d) ->
              if d.val then '#7cd5ff' else 'lightgrey'
            computedHeight = (summedHeights + 2 * transitionCircleRadius + 2 * transitionCircleYPadding) / viewboxWidth * svg.node().getBoundingClientRect().width
            
            svg.transition().duration(transitionSpeed).attr('viewBox', '0 0 ' + viewboxWidth + ' ' + (summedHeights + 2 * transitionCircleRadius + 2 * transitionCircleYPadding)).style 'height', computedHeight + 'px'
            
            return

          transitionToStage4 = ->
            initialText.attr 'class', 'fill-transparent'
            otherTextsWrapper = rectLabelWrapper.append("g")
            otherTexts = otherTextsWrapper
              .selectAll('text')
              .data(testData)
              .enter()
              .append("text")
              .attr('x', xPadding * 2)
              .attr('dy', 0).attr('fill', 'black')
              .attr('font-size', '15px')
              .attr('font-family', 'Arial')
              .attr('class', 'fill-transparent')

            otherArrows = otherTextsWrapper
              .selectAll("path")
              .data(testData)
              .enter()
              .append("path")
              .attr("class", "fill-opacity-hidden")
              .attr("stroke", "none")
              .attr("fill", (d, i) =>
                d.color
              )

            if postAnimationTexts
              postAnimationTexts.attr 'class', 'fill-transparent'
            if postAnimationArrows
              postAnimationArrows.attr 'class', 'fill-transparent'
            rectLabelWrapper.selectAll('rect').transition().duration(transitionSpeed).attr('y', 2 * yPadding) #.attr 'height', initialRectHeight / 1.5 - (2 * yPadding)
            transitionButtons.transition().duration(transitionSpeed).attr('cy', initialRectHeight + transitionCircleYPadding + transitionCircleRadius).attr 'fill', (datum) ->
              if datum.val then '#7cd5ff' else 'lightgrey'
            people.each (d, i) ->
              me = d3.select(this)
              IconArrayUtil.drawPerson(headRadius, me, '#CD913C', true, transitionSpeed)
              return

            rects.transition().duration(transitionSpeed)
              .attr('height', initialText.node().getBBox().height+textPadding)
              .attr('y', 2 * yPadding)

            people.transition().duration(transitionSpeed).attr('transform', (d, i) ->
              col = i % itemsPerRow
              row = Math.floor(i / itemsPerRow)
              xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
              yPosWithinDrawableSpace = yPadding + headRadius + row * (7.0 * headRadius + 2 * personPadding)
              'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
            ).call endall, ->
              if postAnimationTexts
                postAnimationTextWrapper.remove()
              if postAnimationArrows
                postAnimationArrowWrapper.remove()
              initialText.text('This figure summarizes this information. Press play to go through the numbers again, or use the buttons below the figure.').call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2).attr('class', 'fill-black')
              therects = rectLabelWrapper.selectAll('rect')

              therects.transition().duration(transitionSpeed/2).attr("height", initialText.node().getBBox().height+textPadding)

              yPos = initialText.node().getBBox().height+textPadding+(2 * yPadding)+10+(2.5*yPadding)

              otherTexts.text((d) => d.text)
                .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 3)

              summed = 0

              otherTexts
                .attr('y', (d, i) =>
                  last = otherTexts.filter((d, ii) => i-1 is ii)
                  if i > 0
                    summed += last.node().getBBox().height
                  yPos + summed
                )
                .attr('class', 'fill-black')
                #.call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2)

              otherArrows
                .attr("class", "fill-opacity-visible")
                .attr("d", (d, i) =>
                  targetText = otherTexts.filter((d, ii) => i is ii)
                  bbox = targetText.node().getBBox()
                  yBase = bbox.y
                  yHeight = bbox.height
                  path = ""
                  if i == 0
                    path = IconArrayUtil.drawArrow('up', 6, xPadding * 2, yBase+14, true)
                  else if i == 1
                    path = IconArrayUtil.drawArrow('up', 6, xPadding * 2, yBase+14, true)
                  else if i == 2
                    path = IconArrayUtil.drawArrow('right', 6, xPadding * 2 - 2, yBase+7, true)
                  else if i == 3
                    path = IconArrayUtil.drawArrow('down', 6, xPadding * 2, yBase+3, true)
                  else if i == 4
                    path = IconArrayUtil.drawArrow('down', 6, xPadding * 2, yBase+3, true)
                  path
                )

              therects.filter((d, i) => i is 0)
                .transition()
                .duration(transitionSpeed/2)
                .attr('y', initialText.node().getBBox().height+textPadding+(2 * yPadding)+10)
                .attr('height', otherTextsWrapper.node().getBBox().height+textPadding)
                .call endall, ->
                  if outerWrap.node().getBoundingClientRect().height > svg.node().getBoundingClientRect().height
                    newComputedHeight = outerWrap.node().getBoundingClientRect().height
                    newComputedWidth = svg.node().getBoundingClientRect().width
                    scalingFactor = newComputedWidth / newComputedHeight

                    newViewboxHeight = viewboxWidth / scalingFactor
                    svg.transition().duration(transitionSpeed/2)
                    .attr('viewBox', () =>
                      return '0 0 ' + viewboxWidth + ' ' + (newViewboxHeight+1)
                    )
                    .style('height', newComputedHeight + "px")
                    #console.log "NEEDS TO BE BIGGER!"
                    # svg.transition().duration(transitionSpeed)
                    # .attrTween('viewBox', () =>
                    #   () => 
                    #     console.log("viewboxHeight: " + outerWrap.node().getBBox().height)
                    #     console.log("computedHeight: " + outerWrap.node().getBoundingClientRect().height)
                    #     return '0 0 ' + viewboxWidth + ' ' + viewboxHeight
                    # ).style('height', computedHeight + 'px')
              return
            people.selectAll('circle').transition().duration(transitionSpeed).attr('fill', (datum) ->
              datum.color
            ).attr 'stroke', (datum) ->
              datum.color
            people.selectAll('path').transition().duration(transitionSpeed).attr('fill', (datum) ->
              datum.color
            ).attr 'stroke', (datum) ->
              datum.color

            computedHeight = viewboxHeight / viewboxWidth * svg.node().getBoundingClientRect().width

            svg.transition().duration(transitionSpeed)
              .attr('viewBox', '0 0 ' + viewboxWidth + ' ' + viewboxHeight)
              .style('height', computedHeight + 'px')
            return

          transitionButtons.on 'click', (datum, index) ->
            if !autoTransitioning
              if !datum.val
                transitionButtons.each (ld) ->
                  ld.val = false
                  return
                datum.val = true
                if index == 0
                  transitionToStage1 true
                if index == 1
                  transitionToStage2()
                else if index == 2
                  transitionToStage3()
                else if index == 3
                  transitionToStage4()
            return
          transitionToStage1 false
          automateBtn = d3.select('#automate-btn')
          automateBtnIcon = automateBtn.select('i')

          resetCircleTimers = ->
            transitionButtons.attr 'class', 'clickable transition-circle'
            return

          resetTransitioningPoints = ->
            i = 0
            while i < transitionDataPoints.length
              transitionDataPoints[i].val = false
              i++
            resetCircleTimers()
            return

          recomputeSize = ->
            viewBoxAttrs = svg.attr('viewBox').split(/\s+|,/)
            viewboxWidth = parseInt(viewBoxAttrs[2])
            viewboxHeight = parseInt(viewBoxAttrs[3])
            computedWidth = viewboxHeight / viewboxWidth * svg.node().getBoundingClientRect().width
            svg.style 'height', computedWidth + 'px'
            return

          win.on('resize', recomputeSize)

          scope.play = () =>
            if !autoTransitioning
              autoTransitioning = true

              finish = ->
                resetCircleTimers()
                automateBtnIcon.attr 'class', 'fa fa-redo-alt fa-fw'
                autoTransitioning = false
                return

              call4 = (i=3) ->
                #d3.select(transitionButtons.nodes()[3]).dispatch("click");
                resetTransitioningPoints()
                transitionDataPoints[3].val = true
                transitionButton = transitionButtons.filter((d, ii) => ii is i)
                transitionButton.attr 'class', 'clickable transition-circle timed'
                transitionToStage4()
                setTimeout finish, 5000
                return

              call3 = (i=2) ->
                #d3.select(transitionButtons.nodes()[2]).dispatch("click");
                resetTransitioningPoints()
                transitionDataPoints[2].val = true
                transitionButton = transitionButtons.filter((d, ii) => ii is i)
                transitionButton.attr 'class', 'clickable transition-circle timed'
                transitionToStage3()
                setTimeout call4, 5000
                return

              call2 = (i=1) ->
                #d3.select(transitionButtons.nodes()[1]).dispatch("click");
                resetTransitioningPoints()
                transitionDataPoints[1].val = true
                transitionButton = transitionButtons.filter((d, ii) => ii is i)
                transitionButton.attr 'class', 'clickable transition-circle timed'
                transitionToStage2()
                setTimeout call3, 5000
                return

              call1 = (i=0) ->
                #d3.select(transitionButtons.nodes()[0]).dispatch("click");
                resetTransitioningPoints()
                transitionDataPoints[0].val = true
                transitionButton = transitionButtons.filter((d, ii) => ii is i)
                transitionButton.attr 'class', 'clickable transition-circle timed'
                transitionToStage1 true
                setTimeout call2, 5000
                return

              automateBtnIcon.attr 'class', 'fa fa-redo-alt fa-fw fa-spin'
              if !transitionDataPoints[0].val
                call1()
              else
                resetCircleTimers()
                transitionButton = transitionButtons.filter((d, ii) => ii is 0)
                transitionButton.attr 'class', 'clickable transition-circle timed'
                setTimeout call2, 5000
            return
          return
        , 200
]