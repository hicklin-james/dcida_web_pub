'use strict'

mockOptions = {
  message: "Hello!",
  messageSub: "Sub message",
  buttonType: "danger",
  confirmText: "Confirm"
}

describe 'Service: Confirm', ->

  beforeEach angular.mock.module 'dcida20App'

  # mock the uibModal so that we can test some values
  # -----------------------------------------------------------#
  uibModalOptions = null
  modalResolved = false
  modalRejected = false
  mockUibModalInstance = {}
  mockUibModalInstance.result = {
    then: (confirm, cancel) ->
      if confirm
        modalResolved = true
      if cancel
        modalRejected = true
  }
  mockUibModalInstance.close = () ->
    this.result.then(true, false)

  mockUibModalInstance.dismiss = () ->
    this.result.then(false, true)
  
  beforeEach inject ($uibModal) ->
    spyOn($uibModal, 'open').and.callFake (options) ->
      uibModalOptions = options
      modalResolved = false
      modalRejected = false
      return mockUibModalInstance
  # -----------------------------------------------------------#

  Confirm = {}
  _ = {}
  mockScope = {}

  beforeEach inject (_Confirm_, ___, $rootScope) ->
    Confirm = _Confirm_
    _ = ___
    mockScope = $rootScope.$new()

  describe "ConfirmCtrl", () ->
    it "should resolve the promise when confirm() is called", () ->
      uibInstance = Confirm.show(mockOptions)
      expect(modalResolved).toBeFalsy()
      new uibModalOptions.controller(mockScope, mockUibModalInstance).confirm()
      expect(modalResolved).toBeTruthy()

    it "should resolve the promise when close() is called", () ->
      uibInstance = Confirm.show(mockOptions)
      expect(modalResolved).toBeFalsy()
      new uibModalOptions.controller(mockScope, mockUibModalInstance).close()
      expect(modalResolved).toBeTruthy()

    it "should reject the promise when cancel() is called", () ->
      uibInstance = Confirm.show(mockOptions)
      expect(modalRejected).toBeFalsy()
      new uibModalOptions.controller(mockScope, mockUibModalInstance).cancel()
      expect(modalRejected).toBeTruthy()

  describe "AlertCtrl", () ->
    it "should resolve the promise when dismiss() is called", () ->
      uibInstance = Confirm.warning(mockOptions)
      expect(modalResolved).toBeFalsy()
      new uibModalOptions.controller(mockScope, mockUibModalInstance).dismiss()
      expect(modalResolved).toBeTruthy()

  describe "show()", () ->
    it "should open with the ConfirmCtrl", () ->
      uibInstance = Confirm.show(mockOptions)
      expect(uibModalOptions.controller.name).toBe('ConfirmCtrl')

  describe "showWithClose()", () ->
    it "should open with the ConfirmCtrl", () ->
      uibInstance = Confirm.showWithClose(mockOptions)
      expect(uibModalOptions.controller.name).toBe('ConfirmCtrl')

  describe "downloadReady()", () ->
    it "should open with the ConfirmCtrl", () ->
      uibInstance = Confirm.downloadReady(mockOptions)
      expect(uibModalOptions.controller.name).toBe('ConfirmCtrl')

  describe "warning()", () ->
    it "should open with the AlertCtrl", () ->
      uibInstance = Confirm.warning(mockOptions)
      expect(uibModalOptions.controller.name).toBe('AlertCtrl')

  describe "frontendInfo()", () ->
    it "should open with the AlertCtrl", () ->
      uibInstance = Confirm.frontendInfo(mockOptions)
      expect(uibModalOptions.controller.name).toBe('AlertCtrl')

  describe "info()", () ->
    it "should open with the AlertCtrl", () ->
      uibInstance = Confirm.info(mockOptions)
      expect(uibModalOptions.controller.name).toBe('AlertCtrl')

  describe "alert()", () ->
    it "should open with the AlertCtrl", () ->
      uibInstance = Confirm.alert(mockOptions)
      expect(uibModalOptions.controller.name).toBe('AlertCtrl')

  describe "questionResponse()", () ->
    it "should open with the AlertCtrl", () ->
      uibInstance = Confirm.questionResponse(mockOptions)
      expect(uibModalOptions.controller.name).toBe('AlertCtrl')