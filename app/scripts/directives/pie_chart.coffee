'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdPieChart', ['$document', ($document) ->
  templateUrl: "views/directives/chart.html"
  scope:
    chartColors: "&saChartColors"
    chartItems: "=saChartItems"
  controller: PieChartCtrl
]

class PieChartCtrl
  @$inject: ['$scope', '_', 'themeConfig']
  constructor: (@$scope, @_, @themeConfig) ->
    @$scope.ctrl = @

    @$scope.$watch 'chartItems', (nv, ov) =>
      if nv
        @chartItems = nv
        @updatePieData()
    , true

    @colors = @$scope.chartColors() ? @themeConfig["COLORS"]
    @chartItems = @$scope.chartItems

    @chartConfig = 
      options:
        chart:
          type: 'pie'
          animation: false
        colors: @colors
        plotOptions:
          pie:
            allowPointeSelect: true
            cursor: 'pointer'
            dataLabels: 
              enabled: true
              formatter: () ->
                return "<strong>" + this.point.name + "</strong>"
        tooltip:
          enabled: false
          pointFormat: '{series.name}: <b>{point.percentage:.0f}%</b>'
      series: [
        type: 'pie'
        name: 'Importance'
        data: @chartData()
      ]
      title:
        text: "Relative Importance"

  updatePieData: () ->
    @chartConfig.series[0].data = @chartData()

  chartData: () ->
    @_.map @chartItems, (p) => 
      y: p.weight
      color: p.color
      name: p.property_title

