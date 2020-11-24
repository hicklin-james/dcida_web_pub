'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdManChart', ['$document', '$window', '$timeout', '_', ($document, $window, $timeout, _) ->
  scope:
    chartid: "@saChartid"
    data: "=saData"
    maxValue: "@saMaxValue"
  template:"<div id='{{chartid}}-wrapper'>
              <svg id='{{chartid}}' style='height: 0px;'></svg>
            </div>"
  link: (scope, element, attrs) ->
    
    p = null

    # cancel the timeout if the state changes - this prevents
    # errors in d3 when it tries to render the chart AFTER the page
    # has changed and the div no longer exists!
    scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      $timeout.cancel(p)

    default_colors = ['#1f77b4','#ff7f0e','#2ca02c','#d62728','#9467bd','#8c564b','#e377c2','#7f7f7f','#bcbd22','#17becf']

    maxPerRow = 10
    data = [1..scope.maxValue]
    win = angular.element($window)
    id = "#" + scope.chartid
    wrapperid = id + "-wrapper"
    scopeData = scope.data
    #data = scope.data

    colors = null
    if scope.selectedIndex
      colors = _.map data, (datum, index) -> if index is parseInt(scope.selectedIndex) then "#2ca02c" else "#1f77b4"
    else
      colors = default_colors

    barHeight = 20

    canvas = null
    chart = null
    xscale = null
    yscale = null
    circles = null
    labels = null
    labelWrapper = null
    labelIcons = null

    iconArrayWidth = 180
    spaceBetweenChartAndLegend = 30

    circleRadius = 7

    totalLineHeight = circleRadius * 3
    lineHeightPadding = 3
    bottomChartPadding = 10
    topChartPadding = 10
    leftChartPadding = circleRadius * 2
    rightChartPadding = circleRadius * 2
    topSpaceForLegend = 30
    textHeight = 15

    updateChart = (animate) ->
      chartWrapper = d3.select(wrapperid)
      svgWidth = parseInt(chartWrapper.style('width'))
      canvas.style('width', svgWidth)

      drawLabels = () ->

        labelIcons
          .attr('cx', (d, i) -> iconArrayWidth + spaceBetweenChartAndLegend)
          .attr('cy', (d, i) -> topChartPadding + yscale(i+1))
          .attr('r', circleRadius)
          .attr('fill', (d, i) -> default_colors[i])

        labels
          .attr('x', (d, i) -> iconArrayWidth + spaceBetweenChartAndLegend + (circleRadius * 2))
          .attr('y', (d, i) -> topChartPadding + yscale(i+1))
          .text((d) -> d.label)

        # labels
        #   .attr('x', iconArrayWidth + spaceBetweenChartAndLegend)
        #   .attr('y', (d, i) -> topSpaceForLegend + (textHeight * i))
        #   .text((d) -> d.label)

      drawCircles = () ->
        currentDataIndex = 0
        currentDataCounter = 0
        circles
          .attr('cx', (d, i) -> leftChartPadding + xscale(((d-1) % maxPerRow)))
          .attr('cy', (d, i) -> topChartPadding + yscale(Math.ceil(d / maxPerRow)))
          .attr('r', circleRadius)
          .attr('fill', (d, i) ->
            returnVal = ""
            if currentDataIndex < scopeData.length
              currentDataCounter += 1
              resetCounter = false
              if currentDataCounter < scopeData[currentDataIndex].value
                returnVal = default_colors[currentDataIndex]
              else
                returnVal = default_colors[currentDataIndex]
                resetCounter = true
              if resetCounter 
                currentDataCounter = 0 
                currentDataIndex += 1
            else
              returnVal = "lightgrey"

            returnVal
          )

      xscale.range([0, iconArrayWidth])

      drawCircles()
      drawLabels()

    drawChart = () ->
      # chart = d3.select(id)
      # axisWrapper = chart.append("g")
      #   .attr("class", "axis-wrapper")

      xscale = d3.scale.linear()
        .domain([0, maxPerRow])

      rows = Math.ceil(scope.maxValue / maxPerRow)
      dataLength = scopeData.length
      bigger = _.max [rows, dataLength]

      yscale = d3.scale.linear()
        .domain([0, rows])
        .range([0, (totalLineHeight * bigger) - topChartPadding - bottomChartPadding])

      canvas = d3.select(id)
        .style("height", topChartPadding + bottomChartPadding + (totalLineHeight * rows))

      chart = canvas.append('g')

      circles = chart
        .append('g')
        .selectAll('circle')
        .data(data)
        .enter()
        .append('circle')

      labelWrapper = chart
        .append('g')

      labelIcons = labelWrapper
        .selectAll('circle')
        .data(scopeData)
        .enter()
        .append('circle')

      labels = labelWrapper
        .selectAll('text')
        .data(scopeData)
        .enter()
        .append('text')
        .style('dominant-baseline', 'middle')
        .style('font-size', '0.8em')
        .style('font-weight', 'bold')

      updateChart(true)

    win.on 'resize', () ->
      updateChart(false)

    p = $timeout () =>
      drawChart()
    , 200

]

