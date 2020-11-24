'use strict'

module = angular.module('dcida20App')

class IconPickerCtrl
  @$inject: ['$scope', '$uibModalInstance', 'Icon', 'moment', 'Upload', 'options', '_', 'Confirm', 'API_ENDPOINT', 'Util']
  constructor: (@$scope, @$uibModalInstance, @Icon, @moment, @Upload, options, @_, @Confirm, @API_ENDPOINT, @Util) ->
    @$scope.ctrl = @

    @$scope.$watch 'ctrl.fileToUpload', (nv, ov) =>
      if nv
        nnv = nv
        if nv.constructor is Array
          nnv = nv[0]
        reader = new FileReader()
        reader.onload = (evt) =>
          @$scope.$apply () =>
            @cropper.imageToCrop = evt.target.result
        reader.readAsDataURL(nnv)
      

    @loading = true
    @progress = 0
    @dragTo = "123"

    @croppedImage = null
    @cropper = {}
    @selectedFileIds = if options.selectedFileIds then options.selectedFileIds else []
    @iconUrl = null
    @decisionAidId = options.decisionAidId
    @iconType = options.iconType
    @multiSelect = options.multiSelect
    @fileToUpload = null

    # @sortOptions = 
    #   connectWith: '.icons-container'
    #   placeholder: 'new-image'
    #   receive: () =>
    #     if !@multiSelect
    #       @savedImage =  @selectedImages[0] unless  @selectedImages.length is 0
    #   stop: () =>
    #     if !@multiSelect and @savedImage?
    #       @availableImages.push @savedImage
    #       i = @selectedImages.indexOf(@savedImage)
    #       if i > -1
    #         @selectedImages.splice i, 1
    #       @savedImage = null

    @currentTab = 'select'

    @getImages()

  checkIfDropEnabled: (list) ->
    if @draggingImage and list.indexOf(@draggingImage) > -1
      return false
    else
      return true

  testStop: ->
    if !@.ctrl.droppingShouldWork
      @.ctrl.currentlyEditing = @.ctrl.draggingImage
      @.ctrl.draggingImage = null
      @.ctrl.fromList = null
      @.ctrl.toList = null
      @.ctrl.droppingShouldWork = null
      @.ctrl.$scope.$apply()

  testStart: (e, j, img, list) ->
    if !@.ctrl.multiSelect and list is @.ctrl.availableImages
      @.ctrl.oldImage =  @.ctrl.selectedImages[0] unless @.ctrl.selectedImages.length is 0
    @.ctrl.draggingImage = img

    @.ctrl.fromList = list
    @.ctrl.$scope.$apply()

  testOver: (e, j) ->
    @.ctrl.droppingShouldWork = true

  testOut: (e, j) ->
    @.ctrl.droppingShouldWork = false

  testDrop: (e, j) ->
    if @.ctrl.fromList is @.ctrl.selectedImages
      @.ctrl.toList = @.ctrl.availableImages
    else
      @.ctrl.toList = @.ctrl.selectedImages

    if !@.ctrl.multiSelect and @.ctrl.oldImage? and @.ctrl.toList is @.ctrl.selectedImages
      @.ctrl.fromList.push @.ctrl.oldImage
      i = @.ctrl.toList.indexOf(@.ctrl.oldImage)
      if i > -1
        @.ctrl.toList.splice i, 1
      @.ctrl.oldImage = null

    i = @.ctrl.fromList.indexOf(@.ctrl.draggingImage)
    if i > -1
      @.ctrl.fromList.splice i, 1

    @.ctrl.currentlyEditing = @.ctrl.draggingImage

    @.ctrl.draggingImage = null
    @.ctrl.fromList = null
    @.ctrl.toList = null
    @.ctrl.droppingShouldWork = null
    @.ctrl.$scope.$apply()

  setCurrentlyEditing: (img) ->
    @currentlyEditing = img

  resetUpload: () ->
    @cropper = {}
    @iconUrl = null
    @fileToUpload = null

  getImages: () ->
    @Icon.query {decision_aid_id: @decisionAidId}, (images) =>
      @selectedImages = @_.filter images, (i) => @selectedFileIds.indexOf(i.id) > -1
      @availableImages = @_.reject images, (i) => @selectedFileIds.indexOf(i.id) > -1

  setCurrentTab: (tabStr) ->
    @currentTab = tabStr

  uploadImage: () ->
    #croppedImage = new File(@cropper.imageToUpload)
    #croppedImage.dataUrl = @cropper.imageToUpload
    blob = @Util.dataURLToBlob(@croppedImage)

    @inProgress = true
    @Upload.upload(
      url: "#{@API_ENDPOINT}/decision_aids/#{@decisionAidId}/icons"
      fields: {'icon_url': @imageUrl}
      file: blob
    ).progress((evt) =>
      progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
      @progress = progressPercentage
    ).success((data, status, headers, config) =>
      @inProgress = false
      if @multiSelect?
        @selectedImages.push data.icon
      else
        oldSelected = @selectedImages[0] unless @selectedImages.length is 0
        if oldSelected
          @availableImages.push oldSelected
        @selectedImages = [data.icon]

      @currentlyEditing = data.icon
      @currentTab = 'select'
      @resetUpload()
      # change current tab
    ).error((data, status, headers, config) =>
      @inProgress = false
      console.log status
    )

  deleteImage: (img) ->
    @Confirm.show(
      message: 'Are you sure you want to delete this?'
      buttonType: 'danger'
      confirmText: 'Yes'
    ).result.then () =>
      @performDelete(img)

  performDelete: (img) ->
    img.$delete {decision_aid_id: @decisionAidId}, (
      () =>
        i = @_.indexOf @images, img
        if i > -1
          @images.splice i, 1
    ), (
      (error) =>
        if error.data? and error.data.errors == "RecordStillReferenced"
          alert("Cannot delete this item. It is being referenced elsewhere.")
    )

  saveAll: () ->
    @Icon.massUpdate(@selectedImages, @decisionAidId).then (icons) =>
      if @multiSelect
        @$uibModalInstance.close(@selectedImages)
      else
        @$uibModalInstance.close(if @selectedImages.length > 0 then @selectedImages[0] else null)

  cancelImagePicker: () ->
    @$uibModalInstance.dismiss('cancel')

module.controller 'IconPickerCtrl', IconPickerCtrl

