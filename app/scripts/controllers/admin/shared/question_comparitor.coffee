'use strict'

module = angular.module('dcida20App')

module.filter 'html_stripped', () ->
  (input) ->
    if input then input.replace(/<[^>]+>/gm, '') else ''

class QuestionComparitorCtrl
  @$inject: ['$scope', '$uibModalInstance', 'options', '_', 'Confirm', '$timeout']
  constructor: (@$scope, @$uibModalInstance, options, @_, @Confirm, @$timeout) ->
    @$scope.ctrl = @
    @questions = options.questions
    @option = options.option
    @currentQuestion = null

    @visibleOptions = @option.sub_options[..10]

    @$scope.$watch 'ctrl.currentQuestion', (nv, ov) =>
      if nv
        @currentQuestionIndex = @_.findIndex @questions, nv
        @visibleOptions = @option.sub_options[..10]

  loadMore: () ->
    last = @visibleOptions.length
    if last < @option.sub_options.length
      for i in [0..4] by 1
        index = last + i
        if index < @option.sub_options.length
          @visibleOptions.push @option.sub_options[index]
    @watcherCount()

  createOptionResponseHash: () ->
    optionResponseHash = {}
    #@_.each @option.sub_options, (so) =>

  closeQuestionComparitor: () ->
    @$uibModalInstance.dismiss('cancel')

  watcherCount: () ->
    root = angular.element(document.getElementsByTagName('body'))

    watchers = []

    f = (element) =>
      angular.forEach(['$scope', '$isolateScope'], (scopeProperty) =>
        if (element.data() && element.data().hasOwnProperty(scopeProperty)) 
          angular.forEach(element.data()[scopeProperty].$$watchers, (watcher) =>
            watchers.push(watcher)
          )   
      )

      angular.forEach(element.children(), (childElement) =>
          f(angular.element(childElement))
      )

    f(root)

    watchersWithoutDuplicates = []
    angular.forEach(watchers, (item) =>
      if(watchersWithoutDuplicates.indexOf(item) < 0)
        watchersWithoutDuplicates.push(item)
    )

    console.log(watchersWithoutDuplicates.length)

module.controller 'QuestionComparitorCtrl', QuestionComparitorCtrl

