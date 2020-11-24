'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdCircleChart', ['$document', '$window', '$timeout', '_', ($document, $window, $timeout, _) ->
  scope:
    chartid: "@saChartid"
    numSelected: "=saNumSelected"
    numMax: "=saNumMax"
    selectedColor: "=saSelectedColor"
    unselectedColor: "=saUnselectedColor"
  template:"<div id='{{chartid}}-wrapper'>
              <svg id='{{chartid}}' style='height: 0px;'></svg>
            </div>"
  link: (scope, element, attrs) ->

    id = "#" + scope.chartid
    numSelected = scope.numSelected
    numMax = scope.numMax
    data = [numSelected, numMax - numSelected]
    wrapperid = id + "-wrapper"
    color = d3.scale.ordinal().range([scope.selectedColor,scope.unselectedColor])

    win = jQuery($window)

    pie = d3.layout.pie()
      .sort(null)

    updateChart = (animate) ->
      width = parseInt(d3.select(wrapperid).style("width"))
      height = width / 2
      padding = 5
      innerWidth = width - (padding * 2)
      radius = Math.min(width, height) / 2

      chart = d3.select(id)
      chart.style("width", width)
        .style("height", height)

      chartWrapper = chart.select(".chart-wrapper")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

      arc = d3.svg.arc()
        .outerRadius(radius-20)
        .innerRadius(radius-40)

      zeroArc = d3.svg.arc()
        .outerRadius(0)
        .innerRadius(0)

      arcWrapper = chartWrapper.selectAll(".arc")
        .style("fill", (d, i) -> color(i))

      drawText = (ani) ->
        text = chartWrapper.select(".circle-text")
          .style("font-size", "1px")
        
        if ani
          text = text.transition().duration(500)

        text.style("font-size", (d, i) ->
            bbox = this.getBBox()
            cbbox = this.parentNode.getBBox()
            cbboxWidth = cbbox.width - 90
            cbboxHeight = cbbox.height - 90
            Math.min(cbboxWidth/bbox.width, cbboxHeight/bbox.height) + "px"
          )

      arcs = null
      if animate
        n = 0
        arcs = arcWrapper.selectAll("path")
          .each(() -> n++)
          .transition().duration(1000).delay((n, i) -> i * 1000)
            .attrTween("d", (d) ->
              i = d3.interpolate(d.startAngle+0.1, d.endAngle)
              (t) ->
                d.endAngle = i(t)
                arc(d)
            )
          .each("end", () ->
            n--
            if (!n)
              drawText(true)
          )
      else
        arcs = arcWrapper.selectAll("path")
          .attr("d", arc)
        drawText(false)

    drawChart = () ->
      chart = d3.select(id)

      chartWrapper = chart.append("g")
        .attr("class", "chart-wrapper")

      arcWrapper = chartWrapper.selectAll(".arc")
        .data(pie(data)).enter()
          .append("g")
          .attr('class', 'arc')

      arcWrapper.append("path")

      chartWrapper.append("text")
        .attr("class", 'circle-text')
        .attr("dy", "0em")
        .style("dominant-baseline", "central")
        .style("text-anchor", "middle")
        .style("font-size", "1px")
        .text(Math.floor((numSelected / numMax) * 100) + "%")

      updateChart(true)

    $timeout () =>
     drawChart()
    , 200
    
    win.on 'resize', () ->
      updateChart(false)

    scope.$watch "numSelected", (nv, ov) =>
      if ov isnt nv
        numSelected = nv
        d3.select("##{scope.chartid}").selectAll("g").remove()
        data = [numSelected, numMax - numSelected]
        drawChart()

    scope.$watch "numMax", (nv, ov) =>
      if ov isnt nv
        numMax = nv
        data = [numSelected, numMax - numSelected]
        d3.select("##{scope.chartid}").selectAll("g").remove()>
        drawChart()

    scope.$watch "selectedColor", (nv, ov) =>
      if ov isnt nv
        color = d3.scale.ordinal().range([scope.selectedColor,scope.unselectedColor])
        #d3.select("##{scope.chartid}").selectAll("g").remove()
        updateChart()

    scope.$watch "unselectedColor", (nv, ov) =>
      if ov isnt nv
        color = d3.scale.ordinal().range([scope.selectedColor,scope.unselectedColor])
        #d3.select("##{scope.chartid}").selectAll("g").remove()
        updateChart()
]

