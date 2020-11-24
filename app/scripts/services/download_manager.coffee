'use strict'

class DownloadManager
  @$inject: ['Confirm', '$timeout', '$rootScope', '$window', 'API_PUBLIC', 'Auth', 'DecisionAid', 'Util', '_', 'WEBSOCKET_ENDPOINT']
  constructor: (@Confirm, @$timeout, @$rootScope, @$window, @API_PUBLIC, @Auth, @DecisionAid, @Util, @_, @WEBSOCKET_ENDPOINT) ->

  inProgress: () ->
    @downloadInProgress

  performDownloadRequest: (item, fnName, params, dlName, decisionAid) ->
    return null if @downloadInProgress
    @downloadInProgress = true
    r = @setupSocket(dlName, decisionAid)
    # assumes that fn returns a promise with a downloadItem
    @$timeout((() =>
      item[fnName].apply(item, params).then (downloadItem) =>
        # success block
        r
      , (data) =>
        # error block
        error = {}
        if data.errors and data.errors.length > 0
          error.message = data.errors.join(" and ")
        else
          error.message = "An unknown error occured"

        @$timeout.cancel(r.p)
        @unbindChanelEvents(r.userId, r.channel, r.dispatcher, r.channelEvents)
        @handleError(error)
        @downloadInProgress = false
    ), 1000)

  setupSocket: (dlName, decisionAid) ->
    dispatcher = new WebSocketRails("#{@WEBSOCKET_ENDPOINT}")
    channel = dispatcher.subscribe('downloadItems')
    userId = @Auth.currentUserId()
    privateChannelComplete = "complete_#{userId}"
    privateChannelError = "error_#{userId}"
    channelEvents = [privateChannelComplete, privateChannelError]

    p = @$timeout () =>
      @handleError({message: "No response received"})
      @unbindChanelEvents(userId, channel, dispatcher, channelEvents)
      @downloadInProgress = false
    , 300000

    channel.bind privateChannelComplete, (r) =>
      downloadLink = if r.download_item then @API_PUBLIC + '/' + r.download_item.file_location else null
      if downloadLink is null
        r.message = "An unknown error occued"
        @downloadInProgress = false
        @handleError(r)
      else
        @openConfirmModal(downloadLink, dlName, decisionAid)
        @downloadInProgress = false

      @$timeout.cancel(p)
      @unbindChanelEvents(userId, channel, dispatcher, channelEvents)

    channel.bind privateChannelError, (error) =>
      @handleError(error)
      @$timeout.cancel(p)
      @unbindChanelEvents(userId, channel, dispatcher, channelEvents)
      @downloadInProgress = false

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

  openConfirmModal: (downloadLink, dlName, decisionAid) ->
    @Confirm.downloadReady(
      downloadLink: downloadLink
      downloadName: decisionAid.title + dlName
    )

  handleError: (error) ->
    @Confirm.alert(
      message: "Download Failed"
      messageSub: error.message
      buttonType: "default"
      headerClass: 'text-danger'
    )

angular.module('dcida20App').service 'DownloadManager', DownloadManager