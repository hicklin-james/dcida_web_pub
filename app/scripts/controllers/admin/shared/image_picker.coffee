'use strict'

module = angular.module('dcida20App')

class ImagePickerCtrl
  @$inject: ['$scope', '$uibModalInstance', 'MediaFile', 'moment', 'Upload', 'Auth', 'options', '_', 'Confirm', 'API_ENDPOINT']
  constructor: (@$scope, @$uibModalInstance, @MediaFile, @moment, @Upload, @Auth, options, @_, @Confirm, @API_ENDPOINT) ->
    @$scope.ctrl = @
    @loading = true
    @progress = 0

    @selectedFileId = options.selectedFileId
    @selectedFile = null
    @userId = @Auth.currentUserId()
    @currPage = 1

    @currentTab = 'select'

    @getImages()

  getImages: () ->
    @MediaFile.query {user_id: @Auth.currentUserId(), media_type: 'image', page: @currPage}, (images) =>
      @images = images
      if images.$metadata
        @meta = images.$metadata
        @pages = [1..@meta.total_pages]

  updatePage: (page) ->
    if page > 0 && page <= @meta.total_pages
      @currPage = page
      @getImages()

  setCurrentTab: (tabStr) ->
    @currentTab = tabStr

  uploadImage: () ->

    @inProgress = true
    @Upload.upload(
      url: "#{@API_ENDPOINT}/users/#{@Auth.currentUserId()}/media_files"
      fields: {'media_type': 'image'}
      file: @selectedFile
    ).progress((evt) =>
      progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
      @progress = progressPercentage
    ).success((data, status, headers, config) =>
      @inProgress = false
      @selectedFileId = data.media_file.id
      @selectedFile = data.media_file
      @images.push data.media_file
      @closeImagePicker()
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
    img.$delete {user_id: @userId}, (
      () =>
        i = @_.indexOf @images, img
        if i > -1
          @images.splice i, 1
    ), (
      (error) =>
        if error.data? and error.data.errors == "RecordStillReferenced"
          alert("Cannot delete this item. It is being referenced elsewhere.")
    )
  selectImage: (img) ->
    @selectedFile = img
    @selectedFileId = img.id
    @closeImagePicker()

  closeImagePicker: () ->
    @$uibModalInstance.close(@selectedFile)

  cancelImagePicker: () ->
    @$uibModalInstance.dismiss('cancel')




module.controller 'ImagePickerCtrl', ImagePickerCtrl

