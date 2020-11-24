'use strict'

angular.module('dcida20App')
  .factory 'RedactorSettings', ['redactorOptions', 'API_ENDPOINT', 'Auth', 'Storage', '$window', '$uibModal', '$stateParams', (redactorOptions, API_ENDPOINT, @Auth, @Storage, $window, $uibModal, $stateParams) ->

    graphicsPlugin = (userId, decisionAidId) ->
      () =>
        init: () ->
          button = this.button.add('graphics', "Graphics")
          this.button.addCallback(button, this.graphics.show)
          this.button.setAwesome("graphics", 'fa-diamond')
        show: () ->
          # save the previous redactor object, in case
          # we are opening a modal within a modal
          temp = redactorOpened
          redactorOpened = this
          redactorOpened.selection.save()
          modalInstance = $uibModal.open(
            templateUrl: "views/admin/decision_aid/graphic/list.html"
            controller: "GraphicListCtrl"
            size: 'giant'
            resolve:
              options: () ->
                userId: userId
                decisionAidId: decisionAidId
          )

          modalInstance.result.then (graphic) =>
            redactorOpened.selection.restore()
            redactorOpened.insert.html("<span> [graphic id=\"#{graphic.item_id}\"] </span>")
            redactorOpened = temp

    accordionPlugin = (userId, decisionAidId) ->
      () =>
        init: () ->
          button = this.button.add('accordion', 'Accordion')
          this.button.addCallback(button, this.accordion.show)
          this.button.setAwesome('accordion', 'fa-bars')
        show: () ->
          # save the previous redactor object, in case
          # we are opening a modal within a modal
          temp = redactorOpened
          redactorOpened = this
          redactorOpened.selection.save()
          modalInstance = $uibModal.open(
            templateUrl: "views/admin/decision_aid/accordion/list.html"
            controller: "AccordionListCtrl"
            size: 'lg'
            resolve:
              userId: () ->
                userId: userId
              options: () ->
                decisionAidId: decisionAidId
          )

          modalInstance.result.then (accordion) =>
            redactorOpened.selection.restore()
            redactorOpened.insert.html("<span> [accordion id=\"#{accordion.id}\"] </span>")
            redactorOpened = temp

    questionPlugin = (userId, decisionAidId, questionTypes) ->
      possibleQuestionTypes = if questionTypes then questionTypes else 'demographic'
      () =>
        init: () ->
          button = this.button.add('questionSelector', 'Question Selector')
          this.button.addCallback(button, this.questionSelector.show)
          this.button.setAwesome('questionSelector', 'fa-question')
        show: () ->
          temp = redactorOpened
          redactorOpened = this
          redactorOpened.selection.save()
          modalInstance = $uibModal.open(
            templateUrl: "views/admin/shared/question_picker.html"
            controller: "QuestionPickerCtrl"
            size: 'lg'
            resolve:
              options: () ->
                decisionAidId: decisionAidId
                questionType: possibleQuestionTypes
                flatten: false
                includeResponses: true
                questionResponseType: 'radio,text,number,lookup_table,yes_no,json,grid,slider,ranking'
                descriptionText: 'Select a question from the list of questions. 
                  The user response will be dynamically added to the text when the user has answered the question.'
          )

          modalInstance.result.then (question) =>
            redactorOpened.selection.restore()
            str = ""
            if question.additional_meta
              str = "[question id='#{question.id}' #{question.additional_meta}]"
            else
              str = "[question id='#{question.id}']"
            redactorOpened.insert.html("<span> #{str} </span>")
            redactorOpened = temp

    #####################
    # copied from source and modified
    imageManagerPlugin = (userId) =>
      () =>
        init: () ->
          if !this.opts.imageManagerJson 
            return
          this.modal.addCallback('image', this.imagemanager.load)
        load: () ->
          $modal = this.modal.getModal()

          this.modal.createTabber($modal)
          this.modal.addTab(1, 'Upload', 'active')
          this.modal.addTab(2, 'Choose')

          $('#redactor-modal-image-droparea').addClass('redactor-tab redactor-tab1')

          $box = $('<div id="redactor-image-manager-box" style="overflow: auto; height: 300px;" class="redactor-tab redactor-tab2">').hide()
          $footer = $(
            '<div id="redactor-image-manager-footer" style="height: 30px;" class="redactor-tab redactor-tab2">
              <nav aria-label="Page navigation example">
                <ul class="pagination">
                  <li class="page-item"><span class="page-link">Previous</span></li>
                  <li class="page-item"><span class="page-link">Next</span></li>
                </ul>
              </nav>
            </div>'
          ).hide()

          $pagination = $footer.find('.pagination').eq(0)

          $modal.append($box)
          $modal.append($footer)

          pageNum = 1

          getData = (page) =>
            $('#redactor-image-manager-box').find('img').remove()

            $.ajax({
              dataType: "json",
              cache: false,
              url: this.opts.imageManagerJson + "&page=#{page}",
              headers: this.opts.requestHeaders,
              success: $.proxy((data) =>
                if data.media_files
                  $.each(data.media_files, $.proxy((key, val) =>
                    # title
                    thumbtitle = ''
                    if (typeof val.title != 'undefined') 
                      thumbtitle = val.title

                    img = $('<img src="' + val.thumb + '" rel="' + val.image + '" title="' + thumbtitle + '" style="width: 100px; height: 75px; cursor: pointer;" />')
                    $('#redactor-image-manager-box').append(img)
                    $(img).click($.proxy(this.imagemanager.insert, this))
                  ), this)

                if data.meta
                  # delete old nav
                  $footer.find('.page-item').remove()

                  # add new nav
                  prev = $('<li class="page-item"><span class="page-link">Previous</span></li>')
                  if !data.meta.prev_page 
                    prev.addClass("disabled")
                  else
                    prev.click(() =>
                      getData(data.meta.prev_page)
                    )
                  $pagination.append(prev)

                  items = [0...data.meta.total_pages]
                  $.each(items, $.proxy((i) =>
                    node = $("<li class='page-item'><span class='page-link'>#{i+1}</span></li>")
                    if data.meta.curr_page == (i+1)
                      node.addClass("active")
                    node.click(() =>
                      getData(i+1)
                    )
                    $pagination.append(node)
                  ), this)
                  next = $('<li class="page-item"><span class="page-link">Next</span></li>')
                  if !data.meta.next_page 
                    next.addClass("disabled")
                  else
                    next.click(() =>
                      getData(data.meta.next_page)
                    )
                  $pagination.append(next)
              )

            }, this)

          getData(pageNum)

        insert: (e) ->
          this.image.insert('<img src="' + $(e.target).attr('rel') + '" alt="' + $(e.target).attr('title') + '">')
    #####################

    setDefaultSettings: () =>
      # set up the redactor options
      redactorOptions.buttons = ['html', 'formatting', 'bold', 'italic', 'deleted', 
        'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'link', 'alignment', 'horizontalrule']

      redactorOpened = null

      redactorOptions.deniedTags = ['script']

      redactorOptions.imageLink = true
      redactorOptions.replaceDivs = false

      if (!$window.RedactorPlugins) then $window.RedactorPlugins = {}

      #redactorOptions.plugins = ['imagemanager', 'accordion', "graphics", 'questionSelector', "video"]

      redactorOptions.imageUpload = "#{API_ENDPOINT}/users/#{@Auth.currentUserId()}/media_files?is_redactor=true"
      redactorOptions.imageManagerJson = "#{API_ENDPOINT}/users/#{@Auth.currentUserId()}/media_files?media_type=image&is_redactor=true"

    setUserSpecificRedactorOptions: (userId, questionParams, decisionAidId) =>

      token = @Storage.getAccessToken()
      # imageUpload should use the uploadMediaFile action on the API
      # provide is_redactor param so API knows to render array without root key
      redactorOptions.imageUpload = "#{API_ENDPOINT}/users/#{userId}/media_files?is_redactor=true"
      redactorOptions.imageManagerJson = "#{API_ENDPOINT}/users/#{userId}/media_files?media_type=image&is_redactor=true"
      
      # set the requestHeaders so that they include the auth token.
      # note that the redactor and imagemanager source code were altered
      # to support this
      if token?
        redactorOptions.requestHeaders = {"Authorization": "Bearer #{token}"}
      else
        redactorOptions.requestHeaders = {}

      $window.RedactorPlugins.accordion = accordionPlugin(userId, decisionAidId)
      $window.RedactorPlugins.imagemanager = imageManagerPlugin(userId)
      $window.RedactorPlugins.graphics = graphicsPlugin(userId, decisionAidId)

      if questionParams.includeQuestion
        $window.RedactorPlugins.questionSelector = questionPlugin(userId, decisionAidId, questionParams.questionTypes)

  ]
