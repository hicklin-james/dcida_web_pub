'use strict'

angular.module('dcida20App')
  .factory 'IconArrayUtil', ['$q', '_', ($q, _) ->

    wrapText: (text, width, xStart) ->
      text.each ->
        text = d3.select(this)
        words = text.text().split(/\s+/).reverse()
        word = undefined
        line = []
        lineNumber = 0
        lineHeight = 1.1
        y = text.attr('y')
        dy = parseFloat(text.attr('dy'))
        tspan = text.text(null).append('tspan').attr('x', xStart).attr('y', y).attr('dy', dy + 'em')
        while word = words.pop()
          line.push word
          tspan.text line.join(' ')
          if tspan.node().getComputedTextLength() > width
            line.pop()
            tspan.text line.join(' ')
            line = [ word ]
            tspan = text.append('tspan').attr('x', xStart).attr('y', y).attr('dy', ++lineNumber * lineHeight + dy + 'em').text(word)
        return
      return

    drawSmallArrow: (direction, length, startX, startY) ->
      path = ''
      path += 'M ' + startX + ' ' + startY
      if direction == 'down'
        path += ' l 0 ' + length
        path += ' l -5 0'
        path += ' l 6 6'
        path += ' l 6 -6'
        path += ' l -5 0'
        path += ' l 0 ' + -length
      else if direction == 'up'
        path += ' l 0 ' + -length
        path += ' l -5 0'
        path += ' l 6 -6'
        path += ' l 6 6'
        path += ' l -5 0'
        path += ' l 0 ' + length
      else if direction == 'right'
        path += ' l ' + length + ' 0'
        path += ' l 0 4'
        path += ' l ' + -length + ' 0'
      path += ' Z'
      path

    drawArrow: (direction, length, startX, startY, small=false) ->
      x1 = null
      x2 = null

      if small
        x1 = 6
        x2 = 5
      else
        x1 = 12
        x2 = 10

      path = ""
      path += "M " + startX + " " + startY
      if direction == "down"
        path += " l 0 " + length
        path += " l -#{x2} 0"
        path += " l #{x1} #{x1}"
        path += " l #{x1} -#{x1}"
        path += " l -#{x2} 0"
        path += " l 0 " + -length
      else if direction == "up"
        path += " l 0 " + -length
        path += " l -#{x2} 0"
        path += " l #{x1} -#{x1}"
        path += " l #{x1} #{x1}"
        path += " l -#{x2} 0"
        path += " l 0 " + length
      else if direction == "right"
        path += " l " + length + " 0"
        path += " l 0 4"
        path += " l " + -length + " 0"
      path += " Z"
      path

    drawPerson: (headRadius, personWrapper, color, animate, transitionSpeed) ->
      r = headRadius
      headMidBottomX = r
      headMidBottomY = r - (r / 3)
      head = undefined
      if animate
        head = personWrapper.select('circle').transition('head-size-transition').duration(transitionSpeed).attr('r', headRadius * 0.7).attr('cy', 1).attr('stroke-width', 1).attr('stroke', color).attr('fill', color)
      else
        head = personWrapper.select('circle').attr('r', headRadius * 0.7).attr('cy', 1).attr('stroke-width', 1).attr('stroke', color).attr('fill', color)
      # top line
      bodyStartX = -r
      bodyEndX = r
      bodyStartY = headMidBottomY + r/3
      # right shoulder curve
      rightShoulderXCurve1 = bodyEndX + r/3
      rightShoulderYCurve1 = bodyStartY
      rightShoulderXCurve2 = bodyEndX + r/3
      rightShoulderYCurve2 = bodyStartY + r/3
      rightShoulderEndX = bodyEndX + r/3
      rightShoulderEndY = bodyStartY + r/3
      # right arm outer line
      rightArmEndY = rightShoulderEndY + r * 2
      # right hand curve
      rhcx1 = rightShoulderEndX
      rhcy1 = rightArmEndY + r/3
      rhcx2 = rightShoulderEndX - (r/3)
      rhcy2 = rightArmEndY + r/3
      rhex = rightShoulderEndX - (r/3)
      rhey = rightArmEndY
      #right arm inner line
      rightArmInnerEndY = rhey - (r * 2) + r / 2
      # right armpit curve
      racx1 = rhex
      racy1 = rightArmInnerEndY - (r/3)
      racx2 = rhex - (r / 2)
      racy2 = rightArmInnerEndY - (r/3)
      racex = rhex - (r / 2)
      racey = rightArmInnerEndY
      # right leg outer line
      rightLegOuterEndY = racey + r * 4
      # right foot curve
      rfcx1 = racex
      rfcy1 = rightLegOuterEndY + r/3
      rfcx2 = racex - (r/3)
      rfcy2 = rightLegOuterEndY + r/3
      rfcex = racex - (r/3)
      rfcey = rightLegOuterEndY
      # right inner leg
      rightInnerLegEndY = rfcey - (r * 2.6)
      # crotch curve
      crx1 = rfcex
      cry1 = rightInnerLegEndY - (r/3)
      crx2 = -(r * 0.2)
      cry2 = rightInnerLegEndY - (r/3)
      crex = -(r * 0.2)
      crey = rightInnerLegEndY
      # left inner leg
      leftInnerLegEndY = crey + r * 2.6
      # left foot curve
      lfcx1 = crex
      lfcy1 = leftInnerLegEndY + r/3
      lfcx2 = crex - (r/3)
      lfcy2 = leftInnerLegEndY + r/3
      lfcex = crex - (r/3)
      lfcey = leftInnerLegEndY
      # left outer leg
      leftOuterLegEndY = rightArmInnerEndY
      # left armpit curve
      lacx1 = lfcex
      lacy1 = leftOuterLegEndY - (r/3)
      lacx2 = lfcex - (r / 2)
      lacy2 = leftOuterLegEndY - (r/3)
      lacex = lfcex - (r / 2)
      lacey = leftOuterLegEndY
      # left inner arm
      leftInnerArmEndY = rightArmEndY
      # left hand curve
      lhx1 = lacex
      lhy1 = leftInnerArmEndY + r/3
      lhx2 = lacex - (r/3)
      lhy2 = leftInnerArmEndY + r/3
      lhex = lacex - (r/3)
      lhey = leftInnerArmEndY
      # left arm outer
      leftOuterArmEndY = rightShoulderEndY
      # left shoulder curve
      lsx1 = lhex
      lsy1 = leftOuterArmEndY - (r/3)
      lsx2 = bodyStartX
      lsy2 = bodyStartY
      lsex = bodyStartX
      lsey = bodyStartY
      if animate
        personWrapper.select('path').transition('person-size-transition').duration(transitionSpeed).attr('d', ->
          pathString = ''
          pathString += 'M' + bodyStartX + ' ' + bodyStartY
          pathString += ' L ' + bodyEndX + ' ' + bodyStartY
          pathString += ' C ' + rightShoulderXCurve1 + ' ' + rightShoulderYCurve1 + ', ' + rightShoulderXCurve2 + ' ' + rightShoulderYCurve2 + ', ' + rightShoulderEndX + ' ' + rightShoulderEndY
          pathString += ' L ' + rightShoulderEndX + ' ' + rightArmEndY
          pathString += ' C ' + rhcx1 + ' ' + rhcy1 + ', ' + rhcx2 + ' ' + rhcy2 + ', ' + rhex + ' ' + rhey
          pathString += ' L ' + rhex + ' ' + rightArmInnerEndY
          pathString += ' C ' + racx1 + ' ' + racy1 + ', ' + racx2 + ' ' + racy2 + ', ' + racex + ' ' + racey
          pathString += ' L ' + racex + ' ' + rightLegOuterEndY
          pathString += ' C ' + rfcx1 + ' ' + rfcy1 + ', ' + rfcx2 + ' ' + rfcy2 + ', ' + rfcex + ' ' + rfcey
          pathString += ' L ' + rfcex + ' ' + rightInnerLegEndY
          pathString += ' C ' + crx1 + ' ' + cry1 + ', ' + crx2 + ' ' + cry2 + ', ' + crex + ' ' + crey
          pathString += ' L ' + crex + ' ' + leftInnerLegEndY
          pathString += ' C ' + lfcx1 + ' ' + lfcy1 + ', ' + lfcx2 + ' ' + lfcy2 + ', ' + lfcex + ' ' + lfcey
          pathString += ' L ' + lfcex + ' ' + leftOuterLegEndY
          pathString += ' C ' + lacx1 + ' ' + lacy1 + ', ' + lacx2 + ' ' + lacy2 + ', ' + lacex + ' ' + lacey
          pathString += ' L ' + lacex + ' ' + leftInnerArmEndY
          pathString += ' C ' + lhx1 + ' ' + lhy1 + ', ' + lhx2 + ' ' + lhy2 + ', ' + lhex + ' ' + lhey
          pathString += ' L ' + lhex + ' ' + leftOuterArmEndY
          pathString += ' C ' + lsx1 + ' ' + lsy1 + ', ' + lsx2 + ' ' + lsy2 + ', ' + lsex + ' ' + lsey
          pathString
        ).attr('stroke', color).attr('stroke-width', '1').attr 'fill', color
      else
        personWrapper.select('path').attr('d', ->
          pathString = ''
          pathString += 'M' + bodyStartX + ' ' + bodyStartY
          pathString += ' L ' + bodyEndX + ' ' + bodyStartY
          pathString += ' C ' + rightShoulderXCurve1 + ' ' + rightShoulderYCurve1 + ', ' + rightShoulderXCurve2 + ' ' + rightShoulderYCurve2 + ', ' + rightShoulderEndX + ' ' + rightShoulderEndY
          pathString += ' L ' + rightShoulderEndX + ' ' + rightArmEndY
          pathString += ' C ' + rhcx1 + ' ' + rhcy1 + ', ' + rhcx2 + ' ' + rhcy2 + ', ' + rhex + ' ' + rhey
          pathString += ' L ' + rhex + ' ' + rightArmInnerEndY
          pathString += ' C ' + racx1 + ' ' + racy1 + ', ' + racx2 + ' ' + racy2 + ', ' + racex + ' ' + racey
          pathString += ' L ' + racex + ' ' + rightLegOuterEndY
          pathString += ' C ' + rfcx1 + ' ' + rfcy1 + ', ' + rfcx2 + ' ' + rfcy2 + ', ' + rfcex + ' ' + rfcey
          pathString += ' L ' + rfcex + ' ' + rightInnerLegEndY
          pathString += ' C ' + crx1 + ' ' + cry1 + ', ' + crx2 + ' ' + cry2 + ', ' + crex + ' ' + crey
          pathString += ' L ' + crex + ' ' + leftInnerLegEndY
          pathString += ' C ' + lfcx1 + ' ' + lfcy1 + ', ' + lfcx2 + ' ' + lfcy2 + ', ' + lfcex + ' ' + lfcey
          pathString += ' L ' + lfcex + ' ' + leftOuterLegEndY
          pathString += ' C ' + lacx1 + ' ' + lacy1 + ', ' + lacx2 + ' ' + lacy2 + ', ' + lacex + ' ' + lacey
          pathString += ' L ' + lacex + ' ' + leftInnerArmEndY
          pathString += ' C ' + lhx1 + ' ' + lhy1 + ', ' + lhx2 + ' ' + lhy2 + ', ' + lhex + ' ' + lhey
          pathString += ' L ' + lhex + ' ' + leftOuterArmEndY
          pathString += ' C ' + lsx1 + ' ' + lsy1 + ', ' + lsx2 + ' ' + lsy2 + ', ' + lsex + ' ' + lsey
          pathString
        ).attr('stroke', color).attr('stroke-width', '1').attr 'fill', color
  ]
