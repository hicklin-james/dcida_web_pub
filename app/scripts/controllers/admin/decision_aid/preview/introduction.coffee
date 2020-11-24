'use strict'

module = angular.module('dcida20App')

class IntroductionPreviewCtrl
  @$inject: ['$scope', '$state', '$location', 'Auth', 'options', '$uibModalInstance', '$q', 'IntroPage']
  constructor: (@$scope, @$state, @$location, @Auth, options, @$uibModalInstance, @$q, @IntroPage) ->
    @$scope.ctrl = @
    @loading = true
    
    fullDa = options.decisionAid

    @$q.all([fullDa.preview(), @IntroPage.preview(fullDa.id)]).then (promises) =>
      @decisionAid = promises[0]
      @introPages = promises[1]
      @currentIntroPage = @introPages[0]
      @loading = false

  next: () ->
    if @currentIntroPage.intro_page_order < @introPages.length
      @currentIntroPage = @introPages[@currentIntroPage.intro_page_order]

  prev: () ->
    if @currentIntroPage.intro_page_order > 1
      @currentIntroPage = @introPages[@currentIntroPage.intro_page_order-2]

  close: () ->
    @$uibModalInstance.close()

module.controller 'IntroductionPreviewCtrl', IntroductionPreviewCtrl
