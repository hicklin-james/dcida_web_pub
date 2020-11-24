'use strict'

app = angular.module('dcida20App')

app.directive 'sdBotpressWebchat', [ '_', '$http', (_, $http) ->
  restrict: 'E'
  controller: BotpressWebchatCtrl
  templateUrl: "views/directives/botpress_webchat.html"
  scope:
    show: "=saShow"
    decisionAidUserId: "=saDecisionAidUserId"
]

class BotpressWebchatCtrl

  BASE_BOTPRESS_URL: "botpress.jameshicklin.com"
  BASE_SOCKET_URL: "botpress.jameshicklin.com/socket.io"
  BASE_API_URL: "botpress.jameshicklin.com/api/v1/bots/lung-cancer-screening-chatbot/mod/channel-web"

  @$inject: ['$scope', '_', '$http', '$q', '$timeout', '$window', 'Util', 'DecisionAidUserResponse']
  constructor: (@$scope, @_, @$http, @$q, @$timeout, @$window, @Util, @DecisionAidUserResponse) ->
    @$scope.ctrl = @
    @loading = true

    @backEnabled = false
    
    # @$scope.$watch 'decisionAidUser', (nv) =>
    #   console.log "Set the decision aid user to #{nv}"
    #   @userId = nv
    #   @setupConnection()

    @$scope.$on 'dcida.imageLoaded', () =>
      header = jQuery("#decision-aid-header")
      @setupMargins(header, footer, body, messages)

    @$scope.$watch 'show', (nv, ov) =>
      if nv
        @slide()

    win = jQuery(@$window)
    footer = jQuery(".footer").eq(0)
    header = jQuery("#decision-aid-header")
    body = jQuery("body").eq(0)
    messages = jQuery(".chatbot-messages").eq(0)
    @element = jQuery(".outer-chatbot")

    win.bind "scroll", () =>
      header = jQuery("#decision-aid-header")
      hh = header.outerHeight(true)
      if @$window.pageYOffset > hh
        if !@element.hasClass("fixed")
          @element.addClass("fixed")
          @element.css("top", 0)
          @element.css("top", 0)
      else
        if @element.hasClass("fixed")
          @element.removeClass("fixed")
          @element.css("top", hh)

    win.on 'resize', (e) =>
      header = jQuery("#decision-aid-header")
      @setupMargins(header, footer, body, messages)

    @setupMargins(header, footer, body, messages)
    @slide(true)

    @token = @Util.makeId()
    @eio = 3
    @sid = null
    @websocket = null
    @typingInProgress = false
    @lastMessageFromBot = null
    @isVisible = false

    @repeatedFunction = null

    @currentText = ""
    @messages = []
    @userTextMessages = []
    @botTextMessages = []
    @socketHandshakePromise = null

    if @$scope.decisionAidUserId
      @userId = @$scope.decisionAidUserId
      @setupConnection()
    else
      @connectionLost = true

    #@$timeout repeatAliveMessage, 25000

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      if @websocket
        @websocket.close()

      win.unbind "scroll"

  # repeated messages to keep connection alive?
  repeatAliveMessage: () =>
    if @websocket and @websocket.readyState is WebSocket.OPEN
      @websocket.send("2")
      if @repeatedFunction
        #console.log "Cancelling old promise!"
        @$timeout.cancel @repeatedFunction
      @repeatedFunction = @$timeout(@repeatAliveMessage, 25000)
    else
      console.log "Websocket not ready!"

  reconnect: () ->
    @connectionLost = false
    @loading = true
    @setupConnection(true)

  makeInitialReqToGetSid: () =>
    getSidReqUrl = "https://#{@BASE_SOCKET_URL}/?visitorId=#{@userId}&EIO=#{@eio}&transport=polling&t=#{@Util.makeId()}"
    
    @$http({
      method: "GET"
      url: getSidReqUrl
    }).then (response) =>
      @sid = response.data.match(/\"sid\":\"(.*?)\"/)[1]

  identifyGuestToBotpressServer: () =>
    getIdentifyGuestReqUrl = "https://#{@BASE_SOCKET_URL}/?visitorId=#{@userId}&EIO=#{@eio}&transport=polling&t=#{@Util.makeId()}&sid=#{@sid}"
    ident = "40/guest?visitorId=#{@userId},"

    @$http({
      method: "POST"
      url: getIdentifyGuestReqUrl
      headers:
        'Content-Type': "text/plain;charset=UTF-8",
        "Accept": "*/*"
      data: "#{ident.length}:#{ident}"
    })

  openWebSocket: () =>
    d = @$q.defer()
    @websocket = new WebSocket("wss://#{@BASE_SOCKET_URL}/?visitorId=#{@userId}&EIO=#{@eio}&transport=websocket&t=#{@Util.makeId()}&sid=#{@sid}");
    
    @websocket.addEventListener 'message', (event) =>
      @handleIncomingMessage(event)

    @websocket.addEventListener 'open', (event) =>
      console.log "open"
      d.resolve()

    @websocket.addEventListener 'error', (event) =>
      console.log "error"
      console.log event
      d.reject()

    @websocket.addEventListener 'close', (event) =>
      console.log "closed"
      console.log event
      @connectionLost = true

    d.promise

  sendHandshakeToWebsocket: () =>
    d = @$q.defer()
    @websocket.send("2probe")
    # @$timeout () =>
    #   d.resolve()
    # , 10000
    @socketHandshakePromise = d
    
    d.promise

  sendUserAnnounce: () =>
    testMessageReq = "https://#{@BASE_API_URL}/messages/#{@userId}" #?conversationId=23
    @$http({
      method: "POST"
      headers: {
        "Content-Type": "application/json"
      }
      url: testMessageReq,
      data: {type: "visit", text: "User visit", timezone: -2, language: 'en'}
    })

  getConversations: () =>
    d = @$q.defer()
    getConvosReq = "https://#{@BASE_API_URL}/conversations/#{@userId}"

    @$http({
      method: "GET",
      url: getConvosReq
    }).then (response) =>
      if response and response.data and response.data.conversations
        latestConversations = @_.sortBy response.data.conversations, (c) =>
          c.created_on

        if latestConversations.length > 0
          @conversationId = latestConversations[latestConversations.length-1].id
          console.log "Set conversationId to #{@conversationId}"
        else
          console.error "No conversation was found"
      d.resolve(response)
    , (error) =>
      console.log "Error"
      console.log error
      d.reject(error)
    
    d.promise

  startNewConversation: (reconnect) =>
    if reconnect
      d = @$q.defer()
      d.resolve()
      d.promise
    else
      newConvoReq = "https://#{@BASE_API_URL}/conversations/#{@userId}/new"

      @$http({
        method: "POST",
        url: newConvoReq
      })

  getCurrentConversation: () =>
    getConvoReq = "https://#{@BASE_API_URL}/conversations/#{@userId}/" #23"

    @$http({
      method: "GET",
      url: getConvoReq
    })

  resetCurrentConversation: () =>
    resetMessageReq = "https://#{@BASE_API_URL}/conversations/#{@userId}/" #23/reset"

    @$http({
      method: "POST"
      headers: {
        "Content-Type": "application/json"
      }
      url: resetMessageReq
    })

  sendStartMessage: (reconnect) =>
    
    if !reconnect
      replyData =
        text: "start"
        type: "text"

      @sendReply(replyData, false)

  setupConnection: (reconnect) ->

    @makeInitialReqToGetSid()
      .then(@identifyGuestToBotpressServer)
      .then(@openWebSocket)
      .then(@sendHandshakeToWebsocket)
      .then(@sendUserAnnounce)
      .then(@startNewConversation(reconnect))
      .then(@getConversations)
      #.then(@getCurrentConversation)
      #.then(@resetCurrentConversation)
      .then(() =>
        console.log "Finished connecting to bot!"
        @repeatAliveMessage()
        @sendStartMessage(reconnect)
        @loading = false
      )
      .catch((error) =>
        console.error "An error occured setting up the websocket connection"
        console.error error
        @connectionLost = true
        @loading = false
      )

  handleIncomingMessage: (event) ->
    if event.data is "3probe"
      @websocket.send("5")
      # clear the old promise
      @socketHandshakePromise.resolve()
      @socketHandshakePromise = null
    else if event.data.indexOf("42/guest,") >= 0
      messageArr = JSON.parse(event.data.substring(9))
      if messageArr.length > 1
        actualMessage = messageArr[1]
        @handleBotEvent(actualMessage)
      else
        console.log "Unexpected messageArr"
        console.log messageArr
    else
      null
      #console.log "Got some other message..."
      #console.log event

  handleBotEvent: (message) =>
    switch message.name
      when "guest.webchat.message"
        @handleBotMessage(message.data)
      when "guest.webchat.typing"
        @handleBotTyping()
      when "guest.webchat.data"
        @handleBotData(message.data)
      else
        console.log "Unknown message type"
        console.log message

  handleBotData: (data) ->
    switch data.data
      when "enableBack"
        @backEnabled = true
      when "disableBack"
        @backEnabled = false
      else
        console.log "Unknown bot data received"
        console.log data

  handleBotMessage: (messageData) =>
    if messageData.userId
      @handleMessageSentByUser(messageData)
    else
      @handleMessageSentFromBot(messageData)

    @$scope.$apply()

  handleMessageSentByUser: (messageData) =>
    null
    #console.log "Message sent by user!"
    #console.log messageData
    # if messageData.message_type == "text" or messageData.message_type == "quick_reply"
    #   if messageData.message_text == @currentText
    #     @currentText = ""

      #@messages.push messageData

  handleMessageSentFromBot: (messageData) =>
    console.log "Received message from bot!"
    console.log messageData
    if messageData.message_type == "text" or 
       messageData.message_type == "carousel" or
       (messageData.message_type == "custom" and messageData.payload and messageData.payload.quick_replies.length > 0)
      @typingInProgress = false
      @messages.push messageData
      @lastMessageFromBot = messageData

  handleBotTyping: () =>
    #console.log "Typing"
    @typingInProgress = true

  process: (e) =>
    code = (if e then e.keyCode else null)
    if code is 13
      @sendTextReply()

  goBack: () ->
    replyData = 
      payload: "BACK"
      text: "Go back"
      type: "quick_reply"
    @sendReply(replyData)
    @backEnabled = false

  sendQuickReply: (reply, question) =>
    #console.log reply
    replyData = 
      payload: reply.payload
      text: reply.title
      type: "quick_reply"
    
    @sendReply(replyData)

    if question.payload.wrapped.dcidaQuestionId
      @DecisionAidUserResponse.createOrUpdateRadioFromChatbot(@userId, question.payload.wrapped.dcidaQuestionId, reply.payload)

    @backEnabled = true

  sendTextReply: () =>
    @$scope.$broadcast 'killElementFocus'
    
    replyData =
      text: @currentText
      type: "text"

    @currentText = ""

    @sendReply(replyData)

  sendReply: (data, addToMessages=true) =>
    messageReq = "https://#{@BASE_API_URL}/messages/#{@userId}?conversationId=#{@conversationId}"

    @$http({
      method: "POST"
      headers: {
        "Content-Type": "application/json"
      }
      url: messageReq,
      data: data
    })

    if addToMessages
      newMessageData = 
        message_text: data.text
        userId: @userId
      @messages.push newMessageData

    @lastMessageFromBot = null

  setupMargins: (header, footer, body, messages) =>
    hh = header.outerHeight(true)
    fh = footer.outerHeight(true)
    messages.css("height", @$window.innerHeight - hh - 50 - 40)
    @element.css("height", @$window.innerHeight - hh)
    @element.css("top", hh)

  slide: (dontChange=false) ->
    if !dontChange
      @isVisible = !@isVisible
      @$scope.show = @isVisible
    if @isVisible
      @element.css("left", 0)
    else
      widthToUse = Math.max(@$window.innerWidth, 500)
      @element.css("left", -widthToUse)
    return
    


