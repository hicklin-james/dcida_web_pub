'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdLineChart', ['$document', ($document) ->
  templateUrl: "views/directives/chart.html"
  scope:
    chartColors: "&saChartColors"
    chartData: "=saChartData"
  controller: LineChartCtrl
]

class LineChartCtrl
  @$inject: ['$scope', '_', '$timeout', '$window', 'themeConfig']
  constructor: (@$scope, @_, @$timeout, @$window, @themeConfig) ->
    @$scope.ctrl = @

    @importanceLabels = []

    @colors = @themeConfig["COLORS"]
    @chartData = @$scope.chartData
    console.log @chartData
    @drawChart()

    @$timeout () =>
      @$window.dispatchEvent(new Event("resize"));
    , 100

  drawChart: () ->
    @chartConfig = 
      options:
        chart:
          animation: false
          paddingTop: 10
          paddingBottom: 10
        colors: @colors
        legend:
          layout: "vertical"
          align: "right"
          verticalAlign: "middle"
        yAxis:
          title:
            text: @chartData.yLabel
          min: @chartData.minValue
          max: @chartData.maxValue
        xAxis:
          title:
            text: @chartData.xLabel
          categories: @chartData.categories
        exporter:
          enabled: false
        tooltip:
          enabled: false
      series: @_.map(@chartData.data, (dp) =>
        name: dp.label,
        data: @_.map(dp.values, (val) -> parseFloat(val))
      )
      credits:
        enabled: false
      title:
        text: @chartData.title

