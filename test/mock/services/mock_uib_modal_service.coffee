'use strict'

class MockUibModalService
  @$inject: []
  constructor: () ->
    @modalOpened = false

  open: () ->
    @modalOpened = true
    return @

  dismiss: () ->
    @modalOpened = false


angular.module('dcida20AppMock').service 'MockUibModalService', MockUibModalService