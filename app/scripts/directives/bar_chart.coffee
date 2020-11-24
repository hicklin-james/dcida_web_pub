'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdBarChart', ['$document', ($document) ->
  templateUrl: "views/directives/chart.html"
  scope:
    chartColors: "&saChartColors"
    chartItems: "=saChartItems"
  controller: BarChartCtrl
]

class BarChartCtrl
  @$inject: ['$scope', '_', '$timeout', 'themeConfig']
  constructor: (@$scope, @_, @$timeout, @themeConfig) ->
    @$scope.ctrl = @

    @$scope.$watch 'chartItems', (nv, ov) =>
      if nv
        @chartItems = nv
        @updateBarData()
        @$timeout () =>
          @updateImportanceLabels()
    , true

    @importanceLabels = []

    @colors = @$scope.chartColors() ? @themeConfig["COLORS"]
    @chartItems = @$scope.chartItems

    @chartConfig = 
      options:
        chart:
          type: 'column'
          height: 400
          width: 500
          animation: false
          marginRight: 100
          paddingTop: 10
          marginLeft: -15
        colors: @colors
        plotOptions:
          column:
            stacking: 'percent',
            cursor: 'pointer',
            dataLabels: 
              enabled: true
              color: "white"
              overflow: false
              useHTML: true
              style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textOutline": "none", "textShadow": "none", "width": "140px"}
              formatter: () ->
                #"this is a long label that actually wraps onto a second line! "
                if (this.percentage > 15)
                  return "<div style='text-align: center'><strong>" + this.series.name + "</strong> " + this.percentage.toFixed(0) + "%</div>"
                else
                  return ""
        legend:
          enabled: false
        exporter:
          enabled: false
        xAxis:
          categories: ['Values']
          labels:
            enabled: false
        yAxis:
          enabled: false
          offset: -100
          title:
            text: ' '
          labels:
            enabled: false
            formatter: () ->
              if this.isFirst
                "Less Important"
              else if this.isLast
                "More Important"
              else
                ""
            align: 'right'
            style:
              color: "#0079C7"
              fontWeight: "bold"
          stackLabels:
            enabled: false
            style:
              fontWeight: "bold"
        tooltip:
          enabled: false
      series: @chartData()
      title:
        text: ""


    @$timeout () =>
      @updateImportanceLabels()

      #max_index = @_.indexOf @_.max 

    # @chartConfig = 
    #   options:
    #     chart:
    #       type: 'column'
    #       marginLeft: -15
    #       marginRight: 150
    #       height: 400
    #       width: 500
    #       animation: false
    #     colors: @colors
    #     plotOptions:
    #       column:
    #         stacking: 'percent',
    #         cursor: 'pointer',
    #         dataLabels: 
    #           enabled: true
    #           align: 'left'
    #           x: 180
    #           color: "black"
    #           crop: false
    #           overflow: 'none'
    #           formatter: () ->
    #             if (this.percentage > 5)
    #               return "<strong>" + this.series.name + "</strong> " + this.percentage.toFixed(2) + "%"
    #             else
    #               return ""
    #     legend:
    #       enabled: false
    #     xAxis:
    #       categories: ['Values']
    #       labels:
    #         enabled: false
    #     yAxis:
    #       offset: -100
    #       title:
    #         text: ' '
    #       labels:
    #         enabled: true
    #         formatter: () ->
    #           if this.isFirst
    #             "Less Important"
    #           else if this.isLast
    #             "More Important"
    #           else
    #             ""
    #         align: 'right'
    #         style:
    #           color: "#0079C7"
    #           fontWeight: "bold"
    #       stackLabels:
    #         enabled: false
    #         style:
    #           fontWeight: "bold"
    #     tooltip:
    #       headerFormat: '{series.name}<br>'
    #       pointFormat: 'Importance: <b>{point.percentage:.1f}%</b>'
    #       valueDecimals: 1
    #       followPointer: true
    #   series: @chartData()
    #   title:
    #     text: "Relative Importance"

  drawAllEqualText: (chart) ->
    point = chart.series[0].data[0]
    pointWidth = point.shapeArgs.width
    xPos = point.plotX + chart.plotLeft + (pointWidth/2) + 10
    yPos = chart.plotBox.y + (chart.plotBox.height/2)
    @importanceLabels.push chart.renderer.text(
      "All equally important",
      xPos,
      yPos
    ).attr({
      zIndex: 7,
      fill: "black",
      stroke: "black",
      "stroke-width": 1
    }).add()

  drawImportanceLabels: (chart, sorted_data) ->
    @_.each sorted_data, (d) =>
      if d.label and d.value > 5
        point = chart.series[d.index].data[0]
        pointHeight = point.shapeArgs.height
        pointWidth = point.shapeArgs.width
        @importanceLabels.push chart.renderer.text(
          d.label,
          point.plotX + chart.plotLeft + (pointWidth/2) + 10,
          point.shapeArgs.y + (pointHeight / 2) + 13
        ).attr({
          zIndex: 7,
          fill: "black",
          stroke: "black",
          "stroke-width": 1
        }).add()

  updateImportanceLabels: () ->
    chart = @chartConfig.getHighcharts()

    # clear existing importance labels
    @_.each @importanceLabels, (l) =>
      l.destroy()
    @importanceLabels = []

    data = @_.map chart.series, (s, i) => {value: s.data[0].percentage, index: i}
    sorted_data = @_.sortBy data, (d) => d.value
    if sorted_data.length > 0
      min = sorted_data[0]
      min.label = "Least Important"
      max = sorted_data[sorted_data.length-1]
      max.label = "Most important"
      if min.value is max.value
        @drawAllEqualText(chart)
      else
        min_val = min.value
        curr = sorted_data[1]
        i = 1
        while i <= sorted_data.length and curr and curr.value is min_val 
          min.label = "Equally least important"
          curr.label = "Equally least important"
          curr = sorted_data[i+1]
          i += 1

        max_val = max.value
        curr = sorted_data[sorted_data.length - 2]
        i = sorted_data.length - 2
        while i >= 0 and curr and curr.value is max_val 
          max.label = "Equally most important"
          curr.label = "Equally most important"
          curr = sorted_data[i-1]
          i -= 1

        @drawImportanceLabels(chart, sorted_data)
   

  updateBarData: () ->
    data = @chartData()
    @_.each data, (d, r) =>
      sIndex = @_.findIndex @chartConfig.series, (s) => s.prop_id is d.prop_id
      # if it already exists
      if sIndex > -1
        @chartConfig.series[sIndex].data = d.data
        if @complex
          @chartConfig.series[sIndex].index = r
          @chartConfig.series[sIndex].color = d.color
      # if it doesn't exist
      else 
        @chartConfig.series.push(d)
        if @complex
          @chartConfig.series[@chartConfig.series.length-1].index = r
    
    # delete from chart if deleted
    if data.length < @chartConfig.series.length
      index = @_.findIndex @chartConfig.series, (s) => !@_.find data, (d) => d.prop_id is s.prop_id
      if index > -1
        @chartConfig.series.splice(index, 1)

  chartData: () ->
    data_values = @_.map @chartItems, (p) =>
      name: p.property_title
      data: [
        p.weight
      ]
      color: p.color
      prop_id: p.property_id
    
    if @complex  
      data_values.sort (a, b) ->
        aID = a.data[0]
        bID = b.data[0]
        if aID is bID then 0 else if aID < bID then 1 else -1
    else
      data_values

