'use strict'

class MockConfirmService
  @$inject: []
  constructor: () ->
    @modalOpened = false

  alert: () ->
    @modalOpened = true

   warning: () ->
    @modalOpened = true

angular.module('dcida20AppMock').service 'MockConfirmService', MockConfirmService