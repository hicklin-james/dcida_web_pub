'use strict'

app = angular.module('dcida20App')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdGeneralInfoPopup', ['$document', '$uibModal', '$compile', '$templateRequest', ($document, $uibModal, $compile, $templateRequest) ->
  transclude: true
  scope:
    infoTemplateUrl: "@saInfoTemplateUrl"
    title: "@saTitle"
  restrict: "AE"
  template: '<div>
              <a href="" ng-click="openPopup()"><ng-transclude></ng-transclude></a>
            </div>'
            
  link: (scope, element, attrs) ->
    class GeneralInfoCtrl
      @$inject = ['$scope', '$uibModalInstance', 'options']
      constructor: (@$scope, @$uibModalInstance, @options) ->
        @$scope.ctrl = @
        @info = @options.info
        @title = @options.title

      close: -> @$uibModalInstance.dismiss 'close'

    scope.openPopup = () ->
      $templateRequest(scope.infoTemplateUrl).then (html) =>
        #compiledInfo = $compile(html)(scope)
        #console.log compiledInfo
        $uibModal.open(
          templateUrl: "views/directives/general_info_popup_content.html",
          size: 'lg',
          controller: GeneralInfoCtrl,
          resolve:
            options: () ->
              info: html
              title: scope.title
        )

]