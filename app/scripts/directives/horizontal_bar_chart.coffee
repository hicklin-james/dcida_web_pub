'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdHorizontalBarChart', ['$document', '$window', '$timeout', '_', 'Util', ($document, $window, $timeout, _, Util) ->
  scope:
    data: "=saData"
    singleColor: "@saSingleColor"
    maxValue: "@saMaxValue"
    excludePercentages: "@saExcludePercentages"
    selectedIndex: "@saSelectedIndex"
    includeAxis: "@saIncludeAxis"
  template:"<div id='{{chartid}}-wrapper' class='horizontal-bar-chart' style='width: 100%;'>
              <svg id='{{chartid}}'></svg>
            </div>"
  compile: ($element, attr) ->    
      pre: (scope, element) ->
        scope.chartid = Util.makeId()

      post: (scope, element, attrs) ->
        p = null
        globalAnimate = (element.offset().left > -100)

        # cancel the timeout if the state changes - this prevents
        # errors in d3 when it tries to render the chart AFTER the page
        # has changed and the div no longer exists!
        scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
          $timeout.cancel(p)

        scope.$on '$destroy', () ->
          win.off('resize')

        default_colors = ['#a8c3b1','#ff7f0e','#9ad29a','#9dd0c9','#9467bd','#8c564b','#e377c2','#7f7f7f','#bcbd22','#17becf']

        win = angular.element($window)
        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"
        #console.log wrapperid
        data = scope.data

        colors = null
        if scope.selectedIndex
          colors = _.map data, (datum, index) -> if index is parseInt(scope.selectedIndex) then "#1f77b4" else "#d3d3d3"
        else if scope.singleColor
          colors = _.map data, (datum, index) -> scope.singleColor
        else if _.every(data, (datum) => datum.color)
          colors = _.map(data, (datum) => datum.color)
        else
          colors = default_colors

        biggestDataPoint = _.max(data, (d) -> d.value)
        longestLabel = _.max(data, (d) -> d.label.length)

        barHeight = 20
        rightPadding = 25

        canvas = null
        xscale = null
        yscale = null
        xaxis = null
        yaxis = null
        axisOnChart = null
        yaxisOnChart = null
        bars = null
        you = null
        labels = null
        percentageLabels = null
        subSelections = null

        updateChart = (animate) ->
          chartWrapper = d3.select(wrapperid)
          svgWidth = if chartWrapper then parseInt(chartWrapper.style('width')) else 0
          canvas.style('width', svgWidth + "px")

          drawBars = (lw) ->
            bars.attr('width', 0)
              .attr('x', lw + 10)

            if animate
              bars.transition().duration(1000)
                .attr('width', (d, i) -> xscale(d.value))
            else
              bars.attr('width', (d, i) -> xscale(d.value))

          drawSubRects = (lw) ->
            subSelections.attr('x', lw + 10)
            
            if animate
              subSelections.transition().duration(1000)
                .attr('x', (d) -> lw + xscale(if d.sub_value then d.sub_value else 0) - 2)
                .attr('width', (d) -> if d.sub_value then 4 else 0)
            else
              subSelections
                .attr('x', (d) -> lw + xscale(if d.sub_value then d.sub_value else 0) - 2)
                .attr('width', (d) -> if d.sub_value then 4 else 0)

          labels.text((d, i) -> d.label)
          labelWidth = chartWrapper.select(".labels").node()?.getBBox().width
          labels.attr('x', labelWidth)
     
          you.text((d, i) => if i is parseInt(scope.selectedIndex) then "-You" else "") #"⬅ You"
          youWidth = d3.select(wrapperid).select(".you").node()?.getBBox().width

          xscale.range([0, svgWidth - labelWidth - youWidth - rightPadding])

          yscaleaxis = d3.scale.linear()
            .domain([0, data.length-1])
            .range([0, (barHeight*(1+data.length))])

          yaxis.scale(yscaleaxis)

          yaxisOnChart
            .attr("transform", "translate(#{labelWidth+10}, 0) rotate(90)")
            .attr("stroke-width", "2")
            .call(yaxis)

          yaxisOnChart
            .selectAll("path")
            .attr("fill", "none")
            .attr("stroke-width", 2)
            .attr("stroke", 'black')


          if scope.includeAxis
            xaxis.scale(xscale)

            axisOnChart
              .attr('transform', "translate(#{labelWidth + 10}, #{yscale(data.length)})")
              .call(xaxis)

              # rotates the axis
              #.selectAll("text")
              #.attr("y", 0)
              #.attr("x", 9)
              #.attr("dy", ".35em")
              #.attr("transform", "rotate(90)")
              #.style("text-anchor", "start");

            chartWrapper.selectAll(".tick")
              .style("font-size", "11px")

          you.attr('x', (d, i) -> xscale(d.value) + labelWidth + 10)

          if !scope.excludePercentages
           percentageLabels.text((d) -> d.value)
             .attr('x', (d, i) =>
              labelWidth + 15
            )

          drawBars(labelWidth)
          drawSubRects(labelWidth)

        drawChart = () ->
          xscale = d3.scale.linear()
            .domain([0, if scope.maxValue then parseInt(scope.maxValue) else biggestDataPoint.value]) #biggestDataPoint.value])
          
          yaxis = d3.svg.axis()
            .tickValues([0, data.length])
            .tickFormat((d) => return "")
            .outerTickSize(0)
            .innerTickSize(0)

          if scope.includeAxis
            xaxis = d3.svg.axis()
              #.tickValues([0, parseInt(scope.maxValue)])
              .tickFormat((d) => return "#{d}")
              .tickSize(scope.maxValue/10)


          # domain should be number of bars here
          yscale = d3.scale.linear()
            .domain([0, data.length-1])
            .range([0, (barHeight*data.length)])

          # console.log (barHeight * data.length) + (3 * barHeight)
          canvas = d3.select(id)
            .style("height", (barHeight * data.length) + (3 * barHeight) + "px")

          chart = canvas.append('g')
            
          bars = chart
            .selectAll('rect')
            .data(data)
            .enter()
            .append('rect')
            .attr('height', barHeight)
            .attr('x', 0)
            .attr('y', (d, i) -> yscale(i) )
            .style('fill', (d, i) -> colors[i])

          axisOnChart = chart
            .append('g')
            .attr('class', 'xaxis')

          yaxisOnChart = chart
            .append('g')
            .attr('class', 'yaxis')

          you = chart
            .append('g')
            .attr('class', 'you')
            .selectAll('text')
            .data(data)
            .enter()
            .append('text')
            .attr('x', 0)
            .attr('y', (d, i) -> yscale(i) + (barHeight / 2) )
            .attr('dominant-baseline', 'central')
            .attr('font-weight', 'bold')
            .attr('text-anchor', 'start')
            .style('font-size', '11px')

          percentageLabels = chart
            .append('g')
            .attr('class', 'percentageLabels')
            .selectAll('text')
            .data(data)
            .enter()
            .append('text')
            .attr('y', (d, i) -> yscale(i) + (barHeight/2))
            .attr('dominant-baseline', 'central')
            .attr('font-weight', 'bold')
            .attr('fill', (d, i) -> "black")
            .style('font-size', '11px')

          labels = chart
            .append('g')
            .attr('class', 'labels')
            .selectAll('text')
            .data(data)
            .enter()
            .append('text')
            .attr('y', (d, i) -> yscale(i) + (barHeight/2))
            .attr('dominant-baseline', 'central')
            .attr('font-weight', 'bold')
            .attr('text-anchor', 'end')
            .style('font-size', '11px')

          subSelections = chart
            .append('g')
            .attr('class', 'sub-selections')
            .selectAll('rect')
            .data(data)
            .enter()
            .append('rect')
            .attr('height', barHeight)
            .attr('y', (d, i) -> yscale(i))
            .attr('fill', 'red')
            #.attr('fill', 'white')

          updateChart(globalAnimate)

        # in link scope
        win.on 'resize', () ->
          updateChart(false)

         p = $timeout () =>
          drawChart()
        , 0



]