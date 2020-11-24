'use strict'

app = angular.module('dcida20App')

app.directive 'convertToNumber', () ->
  require: "ngModel"
  link: (scope, element, attrs, ngModel) ->
    ngModel.$parsers.push (val) ->
      return if val != null then parseInt(val, 10) else null

    ngModel.$formatters.push (val) ->
      return if val != null then '' + val else null

# when clicking the element, it will trigger a browser back operation
app.directive 'sdAnimatedIconArrayReal', ['$document', '$window', '$timeout', '_', 'Util', '$sce', 'IconArrayUtil', ($document, $window, $timeout, _, Util, $sce, IconArrayUtil) ->
  scope: 
    inputData: "=saInputData"
    indicatorsAbove: "=saIndicatorsAbove"
    defaultStageIndex: "=saDefaultStageIndex"
  template:"<div>
              <div class='text-center' ng-if='indicatorsAbove'>
                <div ng-repeat='step in inputData' class='inline-block step-indicator-wrap' ng-class=\"{'active': csi === $index}\">
                  <div class='step-indicator clickable' ng-class=\"{'animating-in': csi === $index && playingAll, 'not-animating-in': csi === $index && !playingAll}\" ng-click='manGoToStage($index)'></div>
                </div>
                <div class='inline-block top-align'><button class='btn btn-xs btn-info play-all-button' ng-click='playAll()'>Play all &nbsp;<i class='fa fa-refresh' ng-class=\"{'fa-spin': playingAll}\"></i></button></div>
              </div>
              <div id='{{chartid}}-wrapper' class='animated-icon-array-chart' style='width: 100%; height: 100%;'>
                <svg viewBox='0 0 1000 0' preserveAspectRatio='xMidYMid meet' style='width: 100%;' id='{{chartid}}'></svg>
              </div>
              <div class='text-center' ng-if='!indicatorsAbove'>
                <div ng-repeat='step in inputData' class='inline-block step-indicator-wrap' ng-class=\"{'active': csi === $index}\">
                  <div class='step-indicator clickable' ng-class=\"{'animating-in': csi === $index && playingAll, 'not-animating-in': csi === $index && !playingAll}\" ng-click='manGoToStage($index)'></div>
                </div>
                <div class='inline-block top-align'><button class='btn btn-xs btn-info play-all-button' ng-click='playAll()'>Play all &nbsp;<i class='fa fa-refresh' ng-class=\"{'fa-spin': playingAll}\"></i></button></div>
              </div>
            </div>"
  compile: ($element, attr) ->    
    pre: (scope, element) ->
      scope.chartid = Util.makeId()

    post: (scope, element, attrs) ->
      # define all vars that need to stay in scope
      scope.playingAll = false
      lsi = -1
      scope.csi = -1
      win = jQuery($window)
      itemsPerRow = 25 # should be from scope
      otherTestData = undefined # should be from scope
      initialRectHeight = undefined
      viewboxHeight = undefined

      # constants
      chartWidth = 1000
      boxWidth = 370
      xPadding = 10
      yPadding = 10
      rectBorderPadding = 2
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
      textIndicatorOffset = 10
      textLineOffset = 14
      viewboxWidth = 1000
      fontsize = "15px"

      # global vars
      maxHeight = 0

      # containers
      svg = undefined
      outerWrap = undefined

      # vars for labels
      labelWrapper = undefined
      labelTexts = undefined

      # vars for the label rects
      labelRectWrapper = undefined
      labelRects = undefined

      # vars for the icon array people
      peopleWrapper = undefined
      persons = undefined

      # vars for label indicators
      labelIndicators = undefined

      # vars for garbage nodes
      garbageNodes = undefined

      # resizeRectsAndLabels = (newWidth) ->
      #   changeRatio = viewboxWidth / parseInt(newWidth)
      #   fontsize = 17 * changeRatio
      #   labelWrapper.selectAll('text')
      #     .each((d, i, me) ->
      #       label = d3.select(this)
      #       text = label.text()
            
      #       oldLabelHeight = label.node().getBBox().height

      #       label
      #         .attr('font-size', fontsize)
      #         .text(text)
      #         .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2 + textIndicatorOffset)

      #       newLabelHeight = label.node().getBBox().height

      #       labelHeightDiff = null
      #       if newLabelHeight > oldLabelHeight
      #         labelHeightDiff = newLabelHeight - oldLabelHeight
      #       else
      #         labelHeightDiff = oldLabelHeight - newLabelHeight


      #       oldYPos = parseInt(label.attr('y'))

      #       newYPos = oldYPos + (labelHeightDiff / 2)

      #       console.log oldLabelHeight
      #       console.log newLabelHeight
      #       console.log oldYPos
      #       console.log newYPos

      #       label
      #         .attr("y", newYPos)
      #     )

      # win.on 'resize', () ->
      #   newWidth = d3.select("svg").style("width");
      #   resizeRectsAndLabels(newWidth)
        # fontsize = 17 * (1000 / parseInt(newWidth));
        # labelWrapper.selectAll('text')
        #   .attr('font-size', fontsize)

      scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
        win.off 'resize'

      scope.manGoToStage = (index) ->
        if !scope.playingAll
          scope.goToStage(index)

      scope.goToStage = (index) ->
        lsi = scope.csi
        scope.csi = index

        if index isnt lsi
          drawStage(lsi, scope.csi)

      scope.playAll = () ->
        scope.playingAll = true

        if scope.csi is 0
          scope.csi = -1

        # refresh screen to unset csi
        $timeout () ->
          index = -1

          callNext = () ->
            index += 1
            console.log "Playing index: #{index}"
            if index >= scope.inputData.length
              scope.playingAll = false
            else
              scope.goToStage(index)
              setTimeout callNext, 5000
            if !scope.$$phase 
              scope.$digest()

          callNext()

      setupInputData = () ->
        _.each scope.inputData, (d) ->
          d.totalN = [0...d.totalN]

        # scope.inputData = [
        #   {
        #     totalN: ([0...1]),
        #     stepLabel: "This is you.",
        #     separateDataPoints: false,
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "blue"
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     stepLabel: "Imagine there are 100 people like you.",
        #     separateDataPoints: false,
        #     dataPoints: [
        #       {
        #         val: 100,
        #         color: "blue"
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     stepLabel: "Without treatment, in the next year, here is what will happen to these 100 people...",
        #     separateDataPoints: false,
        #     dataPoints: [
        #       {
        #         val: 100,
        #         color: "blue"
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     separateDataPoints: true,
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "grey",
        #         pointLabel: "1 person would die due to other causes."
        #       },{
        #         val: 2,
        #         color: "red",
        #         pointLabel: "2 people would die due to cancer."
        #       },{
        #         val: 97,
        #         color: "blue",
        #         pointLabel: "97 people would survive."
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     stepLabel: "Without treatment, in the next year, of those 100 people",
        #     separateDataPoints: false,
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "grey",
        #         pointLabel: "1 person would die due to other causes."
        #       },{
        #         val: 2,
        #         color: "red",
        #         pointLabel: "2 people would die due to cancer."
        #       },{
        #         val: 97,
        #         color: "blue",
        #         pointLabel: "97 people would survive."
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     stepLabel: "Now, imagine that these 100 people were treated.",
        #     separateDataPoints: false,
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "grey"
        #       },{
        #         val: 2,
        #         color: "red"
        #       },{
        #         val: 97,
        #         color: "blue"
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     separateDataPoints: true,
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "grey",
        #         pointLabel: "1 person would die due to other causes."
        #       },{
        #         val: 1,
        #         color: "red",
        #         pointLabel: "1 person would die due to cancer."
        #       },{
        #         val: 1,
        #         color: "green",
        #         pointLabel: "1 additional survivor due to treatment."
        #       },{
        #         val: 97,
        #         color: "blue",
        #         pointLabel: "97 people would survive."
        #       }
        #     ]
        #   },{
        #     totalN: ([0...100]),
        #     stepLabel: "With treatment, in the next year, of these 100 people:"
        #     separateDataPoints: false,
        #     dataPoints: [
        #       {
        #         val: 1,
        #         color: "grey",
        #         pointLabel: "1 person would die due to other causes."
        #       },{
        #         val: 1,
        #         color: "red",
        #         pointLabel: "1 person would die due to cancer."
        #       },{
        #         val: 1,
        #         color: "green",
        #         pointLabel: "1 additional survivor due to treatment."
        #       },{
        #         val: 97,
        #         color: "blue",
        #         pointLabel: "97 people would survive."
        #       }
        #     ]
        #   }
        # ]

      endall = (transition, callback) ->
        if typeof callback isnt "function" then throw new Error("Wrong callback in endall")
        if transition.size() is 0 then callback()
        n = 0
        transition 
          .each(() => ++n ) 
          .each("end", ()  => if !--n then callback.apply(this, arguments))

      numRectsNeeded = (stage) ->
        if stage.separateDataPoints
          stage.dataPoints.length
        else
          if _.some(stage.dataPoints, (dp) -> !_.isEmpty(dp.pointLabel)) then 2 else 1

      numLabelsNeeded = (stage) ->
        if stage.separateDataPoints
          stage.dataPoints.length
        else
          numDPLabels = _.filter(stage.dataPoints, (dp) -> !_.isEmpty(dp.pointLabel)).length
          numDPLabels + 1

      numLabelIndicatorsNeeded = (stage) ->
        if stage.separateDataPoints
          stage.dataPoints.length
        else
          _.filter(stage.dataPoints, (dp) -> !_.isEmpty(dp.pointLabel)).length

      numPeopleNeeded = (stage) ->
        stage.totalN.length

      addRectToRectWrapper = (lastRect, numRects) ->
        if numRects > 0
          labelRectWrapper
            .append("rect")
            .attr("x", lastRect.attr("x"))
            .attr("y", lastRect.attr("y"))
            .attr("width", lastRect.attr("width"))
            .attr("height", lastRect.attr("height"))
            .attr("stroke", lastRect.attr("stroke"))
            .attr("stroke-width", lastRect.attr("stroke-width"))
            .attr("fill", lastRect.attr("fill"))
        else
          labelRectWrapper
            .append("rect")
            .attr("x", xPadding)
            .attr("width", boxWidth - (4 * xPadding))
            .attr("fill", "white")
            .attr("fill-opacity", 0)
            .attr("stroke", "none")
            .attr("stroke-width", 0)
            .attr("y", yPadding)
            .attr("height", 0)
         
      addLabelToLabelWrapper = (lastLabel, numLabels) ->
        if numLabels > 0
          labelWrapper
            .append("text")
            .attr("x", lastLabel.attr("x"))
            .attr("y", lastLabel.attr("y"))
            .attr("dy", lastLabel.attr("dy"))
            .attr("fill", lastLabel.attr("fill"))
            .attr('font-size', lastLabel.attr("font-size"))
            .attr('font-family', lastLabel.attr("font-family"))
            .attr('class', "fill-transparent")
        else
          labelWrapper
            .append("text")
            .attr("x", xPadding * 2)
            .attr("y", yPadding + rectBorderPadding + textLineOffset)
            .attr("dy", 0)
            .attr("fill", "none")
            .attr("font-size", fontsize)
            .attr('font-family', 'Arial')
            .attr('class', 'fill-black')
            .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2)

      addLabelIndicatorToLabelIndicators = (lastLabelIndicator, currNumLabelIndicators) ->
        if currNumLabelIndicators > 0
          labelIndicators
            .append("circle")
            .attr("cy", lastLabelIndicator.attr("cy"))
            .attr("cx", lastLabelIndicator.attr("cx"))
            .attr("r", lastLabelIndicator.attr("r"))
            .attr("fill", lastLabelIndicator.attr("fill"))
            .attr('stroke', lastLabelIndicator.attr("stroke"))
            .attr('stroke-width', lastLabelIndicator.attr("stroke-width"))
            .attr("fill-opacity", lastLabelIndicator.attr("fill-opacity"))
            .attr("stroke-opacity", lastLabelIndicator.attr("stroke-opacity"))
        else
          labelIndicators
            .append("circle")
            .attr("cy", yPadding + rectBorderPadding)
            .attr("cx", xPadding * 2)
            .attr("r", headRadius/1.2)
            .attr("fill", "white")
            .attr('stroke', "white")
            .attr("fill-opacity", 0)
            .attr("stroke-opacity", 0)
            .attr('stroke-width', "white")

      addPersonToPeopleWrapper = (lastPerson, numPeople) ->
        person = peopleWrapper
          .append("g")

        if numPeople > 0
          lastPersonHead = lastPerson.select("circle")
          lastPersonBody = lastPerson.select("path")

          person
            .attr("transform", lastPerson.attr("transform"))

          personHead = person
            .append("circle")
            .attr('r', lastPersonHead.attr("r"))
            .attr('cy', lastPersonHead.attr("cy"))
            .attr('stroke-width', lastPersonHead.attr("stroke-width"))
            .attr('stroke', lastPersonHead.attr("stroke"))
            .attr('fill', lastPersonHead.attr("fill"))

          personBody = person
            .append("path")
            .attr("d", lastPersonBody.attr("d"))
            .attr("stroke", lastPersonBody.attr("stroke"))
            .attr("stroke-width", lastPersonBody.attr("stroke-width"))
            .attr("fill", lastPersonBody.attr("fill"))

        else
          personHead = person
            .append("circle")
            .attr("fill-opacity", 1)
            .attr("stroke-opacity", 1)

          personBody = person
            .append("path")
            .attr("fill-opacity", 1)
            .attr("stroke-opacity", 1)

          IconArrayUtil.drawPerson(headRadius, person, 'white', false)

      addRectsIfNeeded = (rectsNeeded) ->
        allRects = labelRectWrapper.selectAll("rect")
        currNumRects = allRects.size()
        lastRect = allRects.filter((d, i) -> i == currNumRects - 1)

        if currNumRects < rectsNeeded
          i = 0
          while i < rectsNeeded - currNumRects
            addRectToRectWrapper(lastRect, currNumRects)
            i += 1

      addLabelsIfNeeded = (labelsNeeded) ->
        allLabels = labelWrapper.selectAll("text")
        currNumLabels = allLabels.size()
        lastLabel = allLabels.filter((d, i) -> i == currNumLabels - 1)

        if currNumLabels < labelsNeeded
          i = 0
          while i < labelsNeeded - currNumLabels
            addLabelToLabelWrapper(lastLabel, currNumLabels)
            i += 1

      addLabelIndicatorsIfNeeded = (totalLabelIndicatorsNeeded) ->
        allLabelIndicators = labelIndicators.selectAll("circle")
        currNumLabelIndicators = allLabelIndicators.size()
        lastLabelIndicator = allLabelIndicators.filter((d, i) -> i == currNumLabelIndicators - 1)

        if currNumLabelIndicators < totalLabelIndicatorsNeeded
          i = 0
          while i < totalLabelIndicatorsNeeded - currNumLabelIndicators
            addLabelIndicatorToLabelIndicators(lastLabelIndicator, currNumLabelIndicators)
            i += 1

      addPeopleIfNeeded = (peopleNeeded) ->
        allPeople = peopleWrapper.selectAll("g")
        currNumPeople = allPeople.size()
        lastPerson = allPeople.filter((d, i) -> i == currNumPeople - 1)

        if currNumPeople < peopleNeeded
          i = 0
          while i < peopleNeeded - currNumPeople
            addPersonToPeopleWrapper(lastPerson, currNumPeople)
            i += 1

      setRectAndLabelAttributes = (stage, totalRectsNeeded, totalLabelsNeeded, totalLabelIndicatorsNeeded) ->
        allRects = labelRectWrapper.selectAll("rect")
        allLabels = labelWrapper.selectAll("text")
        allLabelIndicators = labelIndicators.selectAll("circle")
        # draw hidden texts, to get height, then remove
        if stage.separateDataPoints
          # draw people in groups
          rowsNeeded = calcRowsNeededForGrouped(stage)
          rowsUsed = 0
          localGroup = 0
          totalCount = 0
          while localGroup < stage.dataPoints.length
            yBase = ((yPadding / 2) + headRadius + rowsUsed * (6.5 * headRadius + 2 * personPadding))
            yPosWithinDrawableSpace = yBase + 
                                      ((Math.ceil(stage.dataPoints[localGroup].val / itemsPerRow) / 2) * (6.5 * headRadius + 2 * personPadding))

            label = allLabels.filter((d, i) -> i is localGroup)
            labelIndicatorToUse = allLabelIndicators.filter((d, i) -> i is localGroup)

            label
              .attr('class', 'fill-transparent')
              .text(stage.dataPoints[localGroup].pointLabel)
              .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2)

            labelHeight = label.node().getBBox().height

            label
              .attr("y", yPosWithinDrawableSpace - (labelHeight / 2) + textLineOffset)
              .attr("x", xPadding * 2 + textIndicatorOffset)
              .text(stage.dataPoints[localGroup].pointLabel)
              .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2 + textIndicatorOffset)

            labelIndicatorToUse
              .transition()
              .duration(transitionSpeed)
              .attr("cy", yPosWithinDrawableSpace - (labelHeight / 2) + (labelHeight / 2))
              .attr("fill", if stage.dataPoints[localGroup]?.color then stage.dataPoints[localGroup].color else "none")
              .attr("stroke", if stage.dataPoints[localGroup]?.color then stage.dataPoints[localGroup].color else "none")
              .attr("fill-opacity", if stage.dataPoints[localGroup]?.color then 1 else 0)
              .attr("stroke-opacity", if stage.dataPoints[localGroup]?.color then 1 else 0)

            #for ii in [0...stage.dataPoints[localGroup].val]
            rect = allRects.filter((d, i) -> i is localGroup)
            rect.transition()
              .duration(transitionSpeed)
              .attr("y", yPosWithinDrawableSpace - (labelHeight / 2) - rectBorderPadding)
              .attr("height", labelHeight + (rectBorderPadding * 2))
              .call(endall, () ->
                allLabels.attr("class", "fill-black")
              )
            rowsUsed += Math.ceil(stage.dataPoints[localGroup].val / itemsPerRow)
            localGroup += 1
        else
          rectsUsed = 0
          labelsUsed = 0
          heightUsed = 0
          mainLabelRect = allRects.filter((d, i) -> i is 0)
          mainLabel = allLabels.filter((d, i) -> i is 0)
          mainLabel
            .attr("x", xPadding * 2)
            .attr("y", yPadding + rectBorderPadding + textLineOffset)
            .attr("dy", 0)
            .attr("fill", "none")
            .attr("font-size", fontsize)
            .attr('font-family', 'Arial')
            .attr('class', 'fill-transparent')
            .text(stage.stepLabel)
            .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2)

          labelsUsed += 1

          heightUsed = mainLabel.node().getBBox().height

          mainLabelRect
            .transition()
            .duration(transitionSpeed)
            .attr("y", yPadding)
            .attr("height", heightUsed + (2 * rectBorderPadding))
            .call(endall, (d, i) ->
              mainLabel.attr("class", "fill-black")
            )
          rectsUsed += 1

          if _.some(stage.dataPoints, (dp) -> !_.isEmpty(dp.pointLabel))
            secondLabelRect = allRects.filter((d, i) -> i is 1)
            setDataPointLabels = _.filter(stage.dataPoints, (dp) -> !_.isEmpty(dp.pointLabel))
            otherLabels = allLabels.filter((d, i) -> i > 0 and i <= setDataPointLabels.length)
            localHeightUsed = 0
            for i in [0...setDataPointLabels.length]
              labelToUse = otherLabels.filter((d, ii) -> ii is i)
              labelIndicatorToUse = allLabelIndicators.filter((d, ii) -> ii is i)

              labelToUse
                .attr("x", xPadding * 2 + textIndicatorOffset)
                .attr("y", heightUsed + (2 * rectBorderPadding) + (2 * yPadding) + rectBorderPadding + textLineOffset + localHeightUsed)
                .attr("dy", 0)
                .attr("fill", "none")
                .attr("font-size", fontsize)
                .attr('font-family', 'Arial')
                .attr('class', 'fill-transparent')
                .text(setDataPointLabels[i].pointLabel)
                .call(IconArrayUtil.wrapText, boxWidth - (6 * xPadding), xPadding * 2 + textIndicatorOffset)

              labelsUsed += 1

              labelHeight = labelToUse.node().getBBox().height

              console.log
              labelIndicatorToUse
                .transition()
                .duration(transitionSpeed)
                .attr("cy", heightUsed + (2 * rectBorderPadding) + (2 * yPadding) + rectBorderPadding + localHeightUsed + (labelHeight / 2))
                .attr("fill", if stage.dataPoints[i]?.color then stage.dataPoints[i].color else "none")
                .attr("stroke", if stage.dataPoints[i]?.color then stage.dataPoints[i].color else "none")
                .attr("fill-opacity", if stage.dataPoints[i]?.color then 1 else 0)
                .attr("stroke-opacity", if stage.dataPoints[i]?.color then 1 else 0)

              localHeightUsed += labelHeight
              #tempText.remove()
              rectsUsed += 1

            secondLabelRect
              .transition()
              .duration(transitionSpeed)
              .attr("y", heightUsed + (2 * rectBorderPadding) + (2 * yPadding))
              .attr("height", localHeightUsed + (2 * rectBorderPadding))
              .call(endall, (d, i) ->
                otherLabels.attr("class", "fill-black")
              )

            totalRectsHeight = heightUsed + (2 * rectBorderPadding) + (2 * yPadding) + localHeightUsed + (2 * rectBorderPadding) + yPadding
            if totalRectsHeight > maxHeight
              maxHeight = totalRectsHeight

        unusedRects = allRects.filter((d, i) -> i >= totalRectsNeeded)
        unusedLabels = allLabels.filter((d, i) -> i >= totalLabelsNeeded)
        unusedLabelIndicators = allLabelIndicators.filter((d, i) -> i >= totalLabelIndicatorsNeeded)
        unusedLabels
          .attr("class", "fill-transparent")

        unusedLabelIndicators
          .transition()
          .duration(transitionSpeed)
          .attr("cy", yPadding + rectBorderPadding)
          .attr("stroke-opacity", 0)
          .attr("fill-opacity", 0)

        unusedRects
          .transition()
          .duration(transitionSpeed)
          .attr("y", yPadding)
          .attr("height", 0)
          .call(endall, (d, i) ->
            unusedRects.remove()
            unusedLabels.remove()
            unusedLabelIndicators.remove()
          )

      calcRowsNeededForGrouped = (stage) ->
        rowsNeeded = 0
        _.each(stage.dataPoints, (dp) ->
          rowsNeeded += Math.ceil(dp.val / itemsPerRow)
        )
        rowsNeeded

      setPeopleAttributes = (stage, totalPeopleNeeded) ->
        allPeople = peopleWrapper.selectAll("g")
        bucketedColors = _.flatten(_.map(stage.dataPoints, (dp) -> _.map([0...dp.val], (i) -> dp.color)))

        if stage.separateDataPoints
          # draw people in groups
          rowsNeeded = calcRowsNeededForGrouped(stage)
          rowsUsed = 0
          localGroup = 0
          totalCount = 0
          while localGroup < stage.dataPoints.length
            yBase = (yPadding + headRadius + rowsUsed * (6.5 * headRadius + 2 * personPadding))
            for ii in [0...stage.dataPoints[localGroup].val]
              person = allPeople.filter((d, i) -> i is totalCount)
              # allPeople.filter((d, i) -> i is totalCount)
              #   .each((d, i) ->
              #     me = d3.select(this)

              person.transition()
                .duration(transitionSpeed)
                .attr("transform", (d, i) ->
                  col = ii % itemsPerRow
                  if col == 0
                    rowsUsed += 1
                  row = Math.floor(ii / itemsPerRow)
                  xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
                  yPosWithinDrawableSpace = yBase + (row * (6.5 * headRadius + 2 * personPadding))

                  'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
                )

              person.select("circle")
                .transition()
                .duration(transitionSpeed)
                .attr("fill", bucketedColors[totalCount])
                .attr("stroke", bucketedColors[totalCount])

              person.select("path")
                .transition()
                .duration(transitionSpeed)
                .attr("fill", bucketedColors[totalCount])
                .attr("stroke", bucketedColors[totalCount])
                #)

              totalCount += 1

            localGroup += 1

          totalPeopleHeight = (yPadding + headRadius + rowsUsed * (6.5 * headRadius + 2 * personPadding))
          if totalPeopleHeight > maxHeight
            maxHeight = totalPeopleHeight

        else
          allPeople.filter((d, i) -> i < totalPeopleNeeded)
            .transition()
            .duration(transitionSpeed)
            .attr("transform", (d, i) ->
              col = i % itemsPerRow
              row = Math.floor(i / itemsPerRow)
              xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
              yPosWithinDrawableSpace = yPadding + headRadius + row * (6.5 * headRadius + 2 * personPadding)
              'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
            )
            .each((d, i) ->
              me = d3.select(this)
              me.select("circle")
                .transition()
                .duration(transitionSpeed)
                .attr("fill", bucketedColors[i])
                .attr("stroke", bucketedColors[i])

              me.select("path")
                .transition()
                .duration(transitionSpeed)
                .attr("fill", bucketedColors[i])
                .attr("stroke", bucketedColors[i])
            )

          totalPeopleHeight =  yPadding + headRadius + Math.ceil(totalPeopleNeeded / itemsPerRow) * (6.5 * headRadius + 2 * personPadding)
          if totalPeopleHeight > maxHeight
            maxHeight = totalPeopleHeight

        unusedPeople = allPeople.filter((d, i) -> i >= totalPeopleNeeded)
        unusedPeople
          .each(() ->
            me = d3.select(this)
            me.select("circle")
              .transition()
              .duration(transitionSpeed)
              .attr("fill", bucketedColors[totalPeopleNeeded-1])
              .attr("stroke", bucketedColors[totalPeopleNeeded-1])

            me.select("path")
              .transition()
              .duration(transitionSpeed)
              .attr("fill", bucketedColors[totalPeopleNeeded-1])
              .attr("stroke", bucketedColors[totalPeopleNeeded-1])
          )

        unusedPeople
          .transition()
          .duration(transitionSpeed)
          .attr("transform", () ->
            col = (totalPeopleNeeded - 1) % itemsPerRow
            row = Math.floor((totalPeopleNeeded - 1) / itemsPerRow)
            xPosWithinDrawableSpace = boxWidth + xPadding + 1.75 * headRadius + col * (2 * headRadius + headRadius * 1.5)
            yPosWithinDrawableSpace = yPadding + headRadius + row * (6.5 * headRadius + 2 * personPadding)
            'translate(' + xPosWithinDrawableSpace + ',' + yPosWithinDrawableSpace + ')'
          )
          .call(endall, () ->
            unusedPeople.remove()
          )


      drawStage = (currentStageIndex, nextStageIndex) ->
        maxHeight = 0

        currentStage = null
        if currentStageIndex >= 0
          currentStage = scope.inputData[currentStageIndex]
          
        newStage = scope.inputData[nextStageIndex]

        totalRectsNeeded = numRectsNeeded(newStage)
        addRectsIfNeeded(totalRectsNeeded)
        
        totalLabelsNeeded = numLabelsNeeded(newStage)
        addLabelsIfNeeded(totalLabelsNeeded)

        totalLabelIndicatorsNeeded = numLabelIndicatorsNeeded(newStage)
        addLabelIndicatorsIfNeeded(totalLabelIndicatorsNeeded)

        setRectAndLabelAttributes(newStage, totalRectsNeeded, totalLabelsNeeded, totalLabelIndicatorsNeeded)

        totalPeopleNeeded = numPeopleNeeded(newStage)
        addPeopleIfNeeded(totalPeopleNeeded)
        setPeopleAttributes(newStage, totalPeopleNeeded)

        svg
          .transition()
          .duration(transitionSpeed)
          .attr("viewBox", "0 0 1000 #{maxHeight}")

      setupChart = () ->
        svg = d3.select('#' + scope.chartid)
        setupInputData()

        #svgwidth = svg.style("width");
        #fontsize = 17 * (1000 / parseInt(svgwidth));

        outerWrap = svg.append('g')

        garbageNodes = outerWrap
          .append("g")
          .attr("class", "garbage-nodes")

        labelRectWrapper = outerWrap
          .append("g")
          .attr("class", "label-rect-wrapper")

        labelWrapper = outerWrap
          .append("g")
          .attr("class", "label-wrapper")

        peopleWrapper = outerWrap
          .append("g")
          .attr("class", "people-wrapper")

        labelIndicators = outerWrap
          .append("g")
          .attr("class", "label-indicators")

        scope.goToStage(scope.defaultStageIndex)

      # draw actual chart
      $timeout () =>
        setupChart()
      
]