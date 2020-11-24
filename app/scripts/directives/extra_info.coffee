'use strict'

app = angular.module('dcida20App')

# shows a well with additional information that can be expanded
app.directive 'sdExtraInfo', ['$document', 'Util', ($document, Util) ->
  restrict: 'E',
  transclude: true,
  scope: true,
  template:
    '<div class="well clearfix">
      <div class="clearfix">
        <div class="btn-link pull-right">
          <div class="extra-info-button" slide-toggle="#{{randId}}" ng-click="toggleExtraInfo()">
            <i class="fa" ng-class="{\'fa-arrow-down\': !extraInfoVisible, \'fa-arrow-up\': extraInfoVisible}"></i>{{extraInfoVisible ? \' Hide\' : \' Show\'}}
          </div>
          <!-- <div class="extra-info-button" ng-show="extraInfoVisible" ng-click="toggleExtraInfo()"><i class="fa fa-arrow-up"></i> Hide</div> -->
        </div>
        <h4>Page Information</h4>
        <h5>Use the <em>show</em> button on the right to display additional information regarding this page of the decision aid</h5>
      </div>
      <div class="slideable" id="{{randId}}" duration="0.5s">
        <div ng-transclude>
        </div>
      </div>
    </div>'
  link: 
    pre: (scope, element, attrs) ->
      scope.randId = Util.makeId()

    post: (scope, element, attrs) ->
      scope.extraInfoVisible = false

      scope.toggleExtraInfo = () ->
        scope.extraInfoVisible = !scope.extraInfoVisible
]