'use strict'

class UploadManager
  @$inject: ['Confirm', '$timeout', '$rootScope', '$window', 'API_PUBLIC', 'Upload', 'Auth', 'DecisionAid', 'Util', '_', 'WEBSOCKET_ENDPOINT', 'Storage']
  constructor: (@Confirm, @$timeout, @$rootScope, @$window, @API_PUBLIC, @Upload, @Auth, @DecisionAid, @Util, @_, @WEBSOCKET_ENDPOINT, @Storage) ->

  isUploadInProgress: () ->
    @uploadInProgress

  broadcastDecisionAid: (r) ->
    if r.decision_aid
      @$rootScope.$broadcast 'decisionAidChanged', new @DecisionAid r.decision_aid

  performUploadRequest: (params, decisionAid) ->
    @uploadInProgress = true

    r = @setupSocket(decisionAid)
    # assumes that fn returns a promise with a downloadItem
    
    @Upload.upload(
      params
      ).progress((evt) =>
        progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
        @progress = progressPercentage
      ).success((data, status, headers, config) =>
        null
      ).error((data, status, headers, config) =>
        error = {}
        if data.errors and data.errors.length > 0
          error.message = data.errors[0]
        else
          error.message = "An unknown error occured"

        @$timeout.cancel(r.p)
        @unbindChanelEvents(r.userId, r.channel, r.dispatcher, r.channelEvents)
        @handleError(error)
        @uploadInProgress = false
      )

  setupSocket: (dlName, decisionAid) ->
    dispatcher = new WebSocketRails("#{@WEBSOCKET_ENDPOINT}")
    channel = dispatcher.subscribe('uploadItems')
    userId = @Auth.currentUserId()
    privateChannelComplete = "complete_#{userId}"
    privateChannelError = "error_#{userId}"
    channelEvents = [privateChannelComplete, privateChannelError]

    # timeout the socket after 5 minutes. That is unreasonable!
    p = @$timeout () =>
      @handleError({message: "No response received"})
      @unbindChanelEvents(userId, channel, dispatcher, channelEvents)
      @uploadInProgress = false
    , 300000

    channel.bind privateChannelComplete, (r) =>
      @openSuccessModal()
      @$timeout.cancel(p)
      @unbindChanelEvents(userId, channel, dispatcher, channelEvents)
      @uploadInProgress = false
      @broadcastDecisionAid(r)

    channel.bind privateChannelError, (error) =>
      @handleError(error)
      @$timeout.cancel(p)
      @unbindChanelEvents(userId, channel, dispatcher, channelEvents)
      @uploadInProgress = false

    r = 
      userId: userId
      channel: channel
      dispatcher: dispatcher
      channelEvents: channelEvents
      p: p

    return r
      
  unbindChanelEvents: (userId, channel, dispatcher, channelEvents) ->
    @_.each channelEvents, (channelEvent) ->
      channel.unbind channelEvent
    dispatcher.disconnect()

  handleError: (error) ->
    @broadcastDecisionAid(error)

    @Confirm.alert(
      message: "Upload Failed"
      messageSub: error.message
      buttonType: "default"
      headerClass: 'text-danger'
    )

  openSuccessModal: () ->
    @Confirm.alert(
      message: "Success"
      messageSub: "Upload Complete"
      buttonType: "default"
      headerClass: 'text-success'
    )

angular.module('dcida20App').service 'UploadManager', UploadManager