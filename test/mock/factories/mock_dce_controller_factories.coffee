'use strict'

class MockDceStandardCtrl
  @$inject: []
  constructor: () ->
  	@shouldAutosubmit = true
  	@optionConfirmAllowed = true
  	@submitToken = "readyToSave"
  	@resetCalled = false
  
  selectQsr: () ->

  shouldAutosubmit: () ->
  	@shouldAutosubmit

  setOptionConfirmed: () ->
  	@optionConfirmAllowed

  reset: () ->
  	@resetCalled = true

class MockDceConditionalCtrl
  @$inject: []
  constructor: () ->
  	@shouldAutosubmit = true
  	@optionConfirmAllowed = true
  	@submitToken = "readyToSave"
  	@resetCalled = false
  
  selectQsr: () ->

  shouldAutosubmit: () ->
  	@shouldAutosubmit

  reset: () ->
  	@resetCalled = true

class MockDceOptOutCtrl
  @$inject: []
  constructor: () ->
  	@shouldAutosubmit = true
  	@optionConfirmAllowed = true
  	@submitToken = "readyToSave"
  	@resetCalled = false
  
  selectQsr: () ->

  shouldAutosubmit: () ->
  	@shouldAutosubmit

  reset: () ->
  	@resetCalled = true

angular.module('dcida20AppMock').factory 'MockDceStandardCtrl', () -> return MockDceStandardCtrl
angular.module('dcida20AppMock').factory 'MockDceConditionalCtrl', () -> return MockDceConditionalCtrl
angular.module('dcida20AppMock').factory 'MockDceOptOutCtrl', () -> return MockDceOptOutCtrl