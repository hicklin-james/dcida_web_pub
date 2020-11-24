'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdPromsChart', ['$document', '$window', '$timeout', '_', 'Util', ($document, $window, $timeout, _, Util) ->
  scope:
    data: "=saData"
  template:"<div id='{{chartid}}-wrapper' class='proms-bar-chart' style='width: 100%;'>
              <svg  id='{{chartid}}'></svg>
            </div>
            <table class='table-responsive full-width'>
              <tr>
                <td class='col-xs-6 middle-align'>
                  <table class='pull-right'>
                    <tr>
                      <td class='middle-align' style='padding-right: 10px;'>
                        <div style='width: 30px; height: 0; border-top: 3px solid steelblue;'></div>
                      </td>
                      <td>
                        <div style='line-height: 1.1;' class='small'>Quality of life for people like you (age and sex)</div>
                      </td>
                    </tr>
                  </table>
                </td>
                <td class='col-xs-6 middle-align'>
                  <table class='pull-left'>
                    <tr>
                      <td class='middle-align' style='padding-right: 10px;'>
                        <div style='width: 30px; height: 0; border-top: 3px solid lightgreen;'></div>
                      </td>
                      <td>
                        <div style='line-height: 1.1;' class='small'>On average, how quality of life changes for someone like you after surgery.</div>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          "

  compile: ($element, attr) ->    
      pre: (scope, element) ->
        scope.chartid = Util.makeId()

      post: (scope, element, attrs) ->
        p = null
        win = angular.element($window)

        data = scope.data

        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"

        chartParams = {
          height: 600,
          leftPadding: 160,
          rightPadding: 20,
          topPadding: 20,
          bottomPadding: 145,
          xLabelPaddingAddition: 120,
          yLabelPaddingAddition: 55,
          healthLevelOffsets: 25,
          lineOffset: 15
        }

        default_colors = ['#a8c3b1','#ff7f0e','#9ad29a','#9dd0c9','#9467bd','#8c564b','#e377c2','#7f7f7f','#bcbd22','#17becf']
        miny = 0
        maxy = 100

        canvas = null

        xScaleA = null
        xAxisA = null
        xAxisAOnChart = null

        xScaleB = null
        xAxisB = null
        xAxisBOnChart = null

        yScale = null
        yAxis = null
        yAxisOnChart = null

        chartWrapper = null
        barWrapper = null
        barRects = null

        lineWrapper = null
        youLinePath = null
        genPopLinePath = null

        dividerLineWrapper = null
        dividerLine = null

        youLineWrapper = null
        youLine = null

        othersLineWrapper = null
        othersLine = null

        xLabelWrapper = null
        xBeforeLabel = null
        xAfterLabel = null

        yAxisLabelWrapper = null
        yAxisLabel = null

        yAxisBestHealthWrapper = null
        yAxisBestHealthLabel = null

        yAxisWorstHealthWrapper = null
        yAxisWorstHealthLabel = null

        surgeryDateTextWrapper = null
        surgeryDateText = null

        updateChart = (animate=true) ->
          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          canvas.style('width', svgWidth + "px")


          xScaleAWidth = (svgWidth-chartParams.leftPadding-chartParams.rightPadding) / 3
          xScaleA.rangeRoundBands([0, xScaleAWidth], .5);
          xAxisA.scale(xScaleA)

          xAxisAOnChart
            .attr("transform", "translate(#{chartParams.leftPadding}, #{chartParams.height-chartParams.bottomPadding})")
            .call(xAxisA)

          xAxisAOnChart
            .selectAll('text')
            .attr('font-size', 11)
            .attr("transform", "rotate(-65)")
            .style("text-anchor", "end")

          xScaleBWidth = xScaleAWidth * 2
          xScaleB.range([0, xScaleBWidth])
          xAxisB.scale(xScaleB)

          xAxisBOnChart
            .attr("transform", "translate(#{chartParams.leftPadding+xScaleAWidth}, #{chartParams.height-chartParams.bottomPadding})")
            .call(xAxisB)

          lineWrapper
            .attr("transform", "translate(#{chartParams.leftPadding+xScaleAWidth}, #{chartParams.topPadding})")

          dividerLineWrapper
            .attr("transform", "translate(#{chartParams.leftPadding+xScaleAWidth}, #{chartParams.topPadding})")

          dividerLine
            .attr("x1", "0")
            .attr("x2", "0")
            .attr("y1", "0")
            .attr("y2", "#{chartParams.height-chartParams.topPadding-chartParams.bottomPadding}")
            .attr("stroke", "black")
            .attr("fill", "black")
            .attr("stroke-width", 2)

          youLineWrapper
            .attr("transform", "translate(#{chartParams.leftPadding}, #{chartParams.topPadding})")

          youLine
            .attr("x1", xScaleA(1))
            .attr("x2", xScaleAWidth)
            .attr("y1", yScale(data.baseline[1].value))
            .attr('y2', yScale(data.baseline[1].value))
            .attr("stroke", "lightgreen")
            .attr("fill", "lightgreen")
            .attr("stroke-width", 2)

          othersLineWrapper
            .attr("transform", "translate(#{chartParams.leftPadding}, #{chartParams.topPadding})")

          othersLine
            .attr("x1", xScaleA(0))
            .attr("x2", xScaleAWidth)
            .attr("y1", yScale(data.baseline[0].value))
            .attr('y2', yScale(data.baseline[0].value))
            .attr("stroke", "steelblue")
            .attr("fill", "steelblue")
            .attr("stroke-width", 2)

          yAxisOnChart
            .call(yAxis)

          barRects
            .attr('x', (d, i) => xScaleA(i))
            .attr('width', xScaleA.rangeBand())
            .attr('y', (d) => yScale(d.value))
            .attr('height', (d) => chartParams.height-chartParams.topPadding-chartParams.bottomPadding-yScale(d.value))

          youLinePath
            .attr('fill', 'none')
            .attr('stroke', 'lightgreen')
            .attr('stroke-width', 1.5)
            .attr('d', d3.svg.line()
              .x((d) => xScaleB(d.xval))
              .y((d) => yScale(d.yval)))

          genPopLinePath
            .attr('fill', 'none')
            .attr('stroke', 'steelblue')
            .attr('stroke-width', 1.5)
            .attr('d', d3.svg.line()
              .x((d) => xScaleB(d.xval))
              .y((d) => yScale(d.yval)))

          totalYouLength = youLinePath.node().getTotalLength();
          totalGenPopLength = genPopLinePath.node().getTotalLength();
          if animate
            youLinePath
              .attr("stroke-dasharray", totalYouLength)
              .attr("stroke-dashoffset", totalYouLength)
              .transition()
              .duration(3000)
              .ease("linear")
              .attr("stroke-dashoffset", 0);

            genPopLinePath
              .attr("stroke-dasharray", totalGenPopLength)
              .attr("stroke-dashoffset", totalGenPopLength)
              .transition()
              .duration(3000)
              .ease("linear")
              .attr("stroke-dashoffset", 0);
          else
            youLinePath
              .attr("stroke-dasharray", totalYouLength)
              .attr("stroke-dashoffset", 0)

            genPopLinePath
              .attr("stroke-dasharray", totalGenPopLength)
              .attr("stroke-dashoffset", 0)

          xBeforeLabel
            .attr("transform", "translate(#{chartParams.leftPadding+(xScaleAWidth/2)}, #{chartParams.height-chartParams.bottomPadding+chartParams.xLabelPaddingAddition})")
            .attr("text-anchor", "middle")
            .attr("stroke", "back")
            .text("Before Surgery")

          xAfterLabel
            .attr("transform", "translate(#{chartParams.leftPadding+xScaleAWidth+(xScaleBWidth/2)}, #{chartParams.height-chartParams.bottomPadding+chartParams.xLabelPaddingAddition})")
            .attr("text-anchor", "middle")
            .attr("stroke", "back")
            .text("Years After Surgery")

          surgeryDateTextWrapper
            .attr("transform", "translate(#{chartParams.leftPadding+xScaleAWidth+5}, #{chartParams.topPadding})")

          surgeryDateText
            .text("Date of surgery")

        drawChart = () ->
          xScaleA = d3.scale.ordinal()
            .domain([0, data.baseline.length-1])
          xAxisA = d3.svg.axis()
            .orient('bottom')
            .tickFormat((d) => data.baseline[d].label)
            .ticks(2)

          xScaleB = d3.scale.linear()
            .domain([0, _.max(data.postSurgery.youLineData, (datum) => datum.xval).xval])
          xAxisB = d3.svg.axis()
            .orient('bottom')
            .tickFormat((d, i) => i.toString())
            .ticks(5)

          yScale = d3.scale.linear()
            .domain([0, 100])
            .range([chartParams.height-chartParams.topPadding-chartParams.bottomPadding, 0])
          yAxis = d3.svg.axis()
            .orient("left")
            .ticks(10)
            .scale(yScale)

          canvas = d3.select(id)
            .style("height", "#{chartParams.height}px")

          chart = canvas.append('g')

          xAxisAOnChart = chart
            .append('g')
            .attr('class', 'xAxisA')

          xAxisBOnChart = chart
            .append('g')
            .attr('class', 'xAxisB')

          yAxisOnChart = chart
            .append('g')
            .attr('class', 'yAxis')
            .attr('transform', "translate(#{chartParams.leftPadding}, #{chartParams.topPadding})")

          barWrapper = chart
            .append('g')
            .attr('transform', "translate(#{chartParams.leftPadding}, #{chartParams.topPadding})")

          barRects = barWrapper
            .selectAll('rect')
            .data(data.baseline)
            .enter()
            .append('rect')
            .style('fill', (d) => d.color)

          lineWrapper = chart
            .append('g')

          youLinePath = lineWrapper
            .append('path')
            .datum(data.postSurgery.youLineData)

          genPopLinePath = lineWrapper
            .append('path')
            .datum(data.postSurgery.genPopLineData)

          dividerLineWrapper = chart.append('g')
          dividerLine = dividerLineWrapper.append('line')

          youLineWrapper = chart.append('g')
          youLine = youLineWrapper.append('line')

          othersLineWrapper = chart.append('g')
          othersLine = youLineWrapper.append('line')

          xLabelWrapper = chart.append('g')
          xBeforeLabel = xLabelWrapper.append('text')
          xAfterLabel = xLabelWrapper.append('text')

          yAxisLabelWrapper = chart.append('g')
            .attr("transform", "translate(#{chartParams.yLabelPaddingAddition}, #{chartParams.topPadding+((chartParams.height-chartParams.topPadding-chartParams.bottomPadding)/2)})")
          yAxisLabel = yAxisLabelWrapper.append('text')
            .attr("transform", "rotate(-90)")
            .attr("stroke", "black")
            .attr("text-anchor", "middle")
            .text("Quality of life")

          yAxisBestHealthWrapper = chart.append('g')
            .attr("transform", "translate(#{(chartParams.leftPadding/2)-chartParams.healthLevelOffsets}, #{chartParams.topPadding})")
          yAxisBestHealthLabel = yAxisBestHealthWrapper.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', 14)
          yAxisBestHealthLabel.append('tspan')
            .attr('x', 0)
            .attr('y', 0)
            .text('Best health')
          yAxisBestHealthLabel.append('tspan')
            .attr('x', 0)
            .attr('y', chartParams.lineOffset)
            .text('you can imagine')

          yAxisWorstHealthWrapper = chart.append('g')
            .attr("transform", "translate(#{(chartParams.leftPadding/2)-chartParams.healthLevelOffsets}, #{chartParams.height-chartParams.bottomPadding-chartParams.lineOffset})")
          yAxisWorstHealthLabel = yAxisWorstHealthWrapper.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', 14)
          yAxisWorstHealthLabel.append('tspan')
            .attr('x', 0)
            .attr('y', 0)
            .text('Worst health')
          yAxisWorstHealthLabel.append('tspan')
            .attr('x', 0)
            .attr('y', 15)
            .text('you can imagine')

          surgeryDateTextWrapper = chart.append('g')
          surgeryDateText = surgeryDateTextWrapper.append('text')
            .attr("font-size", 16)
            .attr("dominant-baseline", "ideographic")

          updateChart()

        p = $timeout () =>
          drawChart(true)
        , 0

        win.on 'resize', () ->
          updateChart(false)

]