'use strict'

module = angular.module('dcida20App')

class NavCtrl
  @$inject: ['$scope', '$rootScope', '$state', '_', '$stateParams', '$location', 'Auth', 'Storage', 'User', 'authService', 'RedactorSettings', '$uibModal', '$q', '$ngSilentLocation', '$translate', '$window', 'DecisionAidHome']
  constructor: (@$scope, @$rootScope, @$state, @_, @$stateParams, @$location, @Auth, @Storage, @User, @authService, @RedactorSettings, @$uibModal, @$q, @ngSilentLocation, @$translate, @$window, @DecisionAidHome) ->
    @$scope.ctrl = @
    RedactorSettings.setDefaultSettings()

    @user = null
    @decisionAid = null
    @isAdmin = null

    validThemes = ['flat', 'chevron_navigation', 'default']

    @theme = @Storage.getDecisionAidTheme()
    if !@theme or validThemes.indexOf(@theme) < 0
      @theme = 'default'

    @whitelistedParams = ["sub_decision_order", "current_question_set", "page_id", "skip_session_modal", "access_password", "clear_user", "first", "back", "curr_question_page_id", "property_id", "static_page_slug", "curr_intro_page_order"]

    @counter = 0

    @$scope.$on 'dcida.loadingChanged', (e, nv) =>
      @loading = nv.loading
      nv.scope.ctrl.loading = nv.loading
      # if value is now true, set caller's own loading value

    @$scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
      @isAdmin = false
      @isSignIn = false
      if to.data and to.data.admin
        @getUser()
        @isAdmin = true
      else if to.data and to.data.decisionAid
        @isAdmin = false

      else if to.data and to.data.signin
        @isSignIn = true

      @daError = null
      @stateName = null
      #@currentPage = null
      @openSessionModal = false
      # if this is a front-end navigation change and there is 
      # a uuid or pid in the params
      
      # temporary for HSF application
      if top.slug is "SPARC-DT2"
        top.slug =  "SPARC-DT"
        @ngSilentLocation.silent("/decision_aid/SPARC-DT")

      if top.clear_user
        @Storage.clearFrontEndData()
        @openSessionModal = (if top.skip_session_modal then false else true)
        @$stateParams.clear_user = null
        top.clear_user = null
        top.skip_session_modal = null
        @$stateParams.skip_session_modal = null

      @extra_params = @$location.search()
      @_.each @whitelistedParams, (wlp) =>
        delete @extra_params[wlp]

      if !@isAdmin and !@isSignIn and (!@_.isEmpty(@extra_params) or top.access_password) #(top.uuid? or top.pid? or top.psid? or top.patient_id? or top.p_id or top.access_password?)
        id_name = ""
        id_val = null
        # psid -> pid -> p_id -> patient_id
        if top.psid?
          id_name = "psid"
          id_val = top.psid
        else if top.pid?
          id_name = "pid"
          id_val = top.pid
        else if top.p_id?
          id_name = "p_id"
          id_val = top.p_id
        else if top.patient_id?
          id_name = "patient_id"
          id_val = top.patient_id

        params = 
          slug: top.slug
          decision_aid_password: top.access_password 
          query_params: @extra_params
          static_page_slug: top.static_page_slug

        # get the user specified in the params
        @getDecisionAidUser(params, to.name, top.slug, @openSessionModal)
        # prevent the state change
        e.preventDefault()
      else
        if top.back and top.back is "true" and !@goingOverSkipped and to.name isnt from.name
          # we should find the last unskipped state and go there instead, assuming the last state was skipped...
          currentPageIndexInUnfilteredList = @_.findIndex @unfilteredPages, (p) => "decisionAid#{p.page_name}" is from.name
          if @unfilteredPages and @unfilteredPages[currentPageIndexInUnfilteredList-1] and @unfilteredPages[currentPageIndexInUnfilteredList-1].skipped
            currentPageIndex = @_.findIndex @allPages, (p) => "decisionAid#{p.page_name}" is from.name
            if currentPageIndex and @allPages[currentPageIndex - 1]
              e.preventDefault()
              @goingOverSkipped = true
              @$state.go "decisionAid#{@allPages[currentPageIndex - 1].page_name}", {slug: top.slug, back: true}
        else
          @goingOverSkipped = false


    @$scope.$on 'dcida.userChanged', (e, user) =>
      @user = user

    @$scope.$on 'dcida.goToPage', (e, data) =>
      if data.url_to_skip_to
        sectionTarget = @_.find @unfilteredPages, (p) => p.kn is data.url_to_skip_to
        @$statePa
        @$state.go "decisionAid#{sectionTarget.page_name}", {slug: @decisionAid.slug}, {reload: true, inherit: false}

    @$scope.$on 'dcida.decisionAidFound', (event, data) =>
      # on decisionAidFound, set some variables on the controller to update
      # the UI
      @decisionAid = data.decisionAid

      @theme = @decisionAid.theme
      if !@theme or validThemes.indexOf(@theme) < 0
        @theme = 'default'

      @Storage.setDecisionAidTheme(@theme)

      if @Storage.getDecisionAidSlug() isnt @decisionAid.slug
        @Storage.setDecisionAidSlug(@decisionAid.slug)

      @unfilteredPages = @_.toArray data.pages
      filteredPages = @_.filter(data.pages, (p) -> !p.skipped)
      @_.each filteredPages, (p, i) ->
        p.page_index = i
      @$translate.use(@decisionAid.language_code)
      @allPages = @_.toArray(filteredPages)
      @pages = @chunk(@_.sortBy(filteredPages, 'page_index'))

      @indexedPages = @_.indexBy filteredPages, 'page_name'
      @sortedPages = @_.sortBy(filteredPages, 'page_index')
      @pageIndexedPages = @_.indexBy filteredPages, 'page_index'
      @pageParams = @$stateParams

      @stateName = @$state.current.name
      pageKey = @stateName.replace("decisionAid", "").replace(/([A-Z])/g, (p, p1, pos) -> (if pos > 0 then "_" else "") + p.toLowerCase())
      pageKey = pageKey.charAt(0).toLowerCase() + pageKey.slice(1)

      # set the sub decision order on the pageParams
      if @$state.current.name is "decisionAidResults"
        if @pageParams.sub_decision_order 
          @pageParams.sub_decision_order = parseInt(@pageParams.sub_decision_order)
          pageKey += "_#{@pageParams.sub_decision_order}"
        if @pageParams.sub_decision_order is undefined
          @pageParams.sub_decision_order = 1
          pageKey += "_1"


      @currentPage = @_.find @allPages, (p) => p.key is pageKey

      @decision_aid_user = data.decisionAidUser
      @$rootScope.$broadcast 'decisionAidUserSet', @decision_aid_user.id

    @$scope.$on 'dcida.percentageCompletedUpdate', (event, data) =>
      null
      # if data.checkNextPage
      #   pageIndex = @_.findIndex @sortedPages, (p) => 
      #     p.page_name is @currentPage.page_name
      #   if pageIndex >= 0 and @sortedPages[pageIndex+1]
      #     nextPage = @sortedPages[pageIndex+1]
      #     @pc = (if nextPage.available then 100 else 0)
      #   else
      #     @pc = 100
      # else
      #   @pc = Math.round(data.percentageCompleted * 100)

    @$scope.$watch 'ctrl.$state.current', (newVal, oldVal) =>
      #console.log newVal
      # @isAdmin = false
      # @isSignIn = false
      # if newVal.data and newVal.data.admin
      #   @getUser()
      #   @isAdmin = true
      # else if newVal.data and newVal.data.decisionAid
      #   @isAdmin = false

      # else if newVal.data and newVal.data.signin
      #   @isSignIn = true

    @$scope.$on 'event:auth-loginRequired', (e, response) =>
      #console.log "login required, confirming login..."
      @confirmLogin(response)

  openHelpMe: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/decision_aid/contact_help.html"
      controller: "ContactHelpCtrl"
      size: 'lg'
      resolve:
        options: () =>
          description: @decisionAid.description
    )

  signOut: () ->
    @Auth.signOut().then () =>
      @user = null
      @$state.go "signin"
    ,(error) =>
      console.log error

  pageStateName: (page) ->
    "decisionAid#{page.page_name}"

  goToPage: (page) ->
    if page.available
      #console.log "decisionAid#{page.page_name}({slug: '#{@decisionAid.slug}'})"
      params = 
        slug: @decisionAid.slug

      if page.page_params
        params = @_.extend params, page.page_params

      #console.log params

      @$state.go "decisionAid#{page.page_name}", params, {reload: true}

  openAdminModal: () ->
    if !@modalOpen
      modalInstance = @$uibModal.open(
        templateUrl: "/views/admin/modal_signin.html"
        controller: "SigninModalCtrl"
        size: 'md'
        backdrop: 'static'
      )
      # ensure that modal only opens once if there
      # are multiple 401 responses - eg. in the case
      # of a q.all with multiple request promises
      @modalOpen = true

      modalInstance.result.then () =>
        @authService.loginConfirmed null, (config) =>
          @modalOpen = false
          config
      , (error) =>
        @modalOpen = false
        @authService.loginCancelled()


  openActualDecisionAidSessionModal: (params, deferred) ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/new_session.html"
      controller: "NewSessionCtrl"
      size: 'lg'
      backdrop: 'static'
    )

    modalInstance.result.then (ids) =>
      # if ids.uuid?
      #   params.uuid = ids.uuid
      qps = {}
      if ids.pid?
        qps.pid = ids.pid

      params.query_params = qps

      deferred.resolve(params)

  openDecisionAidSessionModal: (params) ->
    d = @$q.defer()
    @DecisionAidHome.getLanguage(params.slug).then (language) =>
      if language.lang
        @$translate.use(language.lang)
      @openActualDecisionAidSessionModal(params, d)
    , (error) =>
      @openActualDecisionAidSessionModal(params, d)

    d.promise

  openCurrentSessionModal: () ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/current_session.html"
      controller: "CurrentSessionCtrl"
      size: "lg"
      resolve:
        options: () =>
          decisionAidUser: @decision_aid_user
    )

  openPasswordModal: (lastParams, stateToName, slug) ->
    modalInstance = @$uibModal.open(
      templateUrl: "/views/home/decision_aid_password.html"
      controller: "DecisionAidPasswordCtrl"
      size: 'lg'
      backdrop: 'static'
    )

    modalInstance.result.then (password_attempt) =>
      lastParams.decision_aid_password = password_attempt
      @getDecisionAidUser(lastParams, stateToName, slug, @openSessionModal)

  confirmLogin: (response) ->
    currentState = @$state.current
    #console.log(JSON.stringify(currentState))
    if currentState.data and currentState.data.admin
      # show admin login popup
      if @Auth.hasToken()
        @openAdminModal()
      else
       @$state.go 'signin'
    else if currentState.data and currentState.data.decisionAid
      #console.log "current state is frontend"
      if response.data and response.data.error is "page_restricted"
        @authService.loginCancelled()
        console.error "No permission to be here!"
        @$state.go "decisionAidIntro", {slug: @$stateParams.slug}, {reload: true}
      else
        # create new user
        @getDecisionAidUser({pid: null, uuid: null, slug: @$stateParams.slug, decision_aid_password: @$stateParams.access_password}, @$state.$current.name, @$stateParams.slug, @openSessionModal).then (data) =>
          if data.meta.is_new_user? and data.meta.is_new_user is false
            @authService.loginConfirmed()
          else
            #console.log "Do i end up here???"
            @authService.loginCancelled()
            if @$stateParams.static_page_slug
              #console.log "Going to static page"
              #console.log {slug: @$stateParams.slug, static_page_slug: @$stateParams.static_page_slug}
              @$state.go "decisionAidStaticPage", {slug: @$stateParams.slug, static_page_slug: @$stateParams.static_page_slug}, {reload: true}
              #console.log "go to static page"
            else
              #console.log "go to intro"
              @$state.go "decisionAidIntro", {slug: @$stateParams.slug}, {reload: true}

            #@$state.go "decisionAidIntro", {slug: @$stateParams.slug}, {reload: true}
        , (error) =>
          @authService.loginCancelled()
    else
      @authService.loginCancelled()

  chunk: (arr) ->
    newArr = [[],[]]
    start = 0
    midpoint = Math.floor(arr.length / 2)
    highCounter = midpoint

    while start < arr.length
      if start <= midpoint
        newArr[0].push arr[start]
      else
        newArr[1].push arr[start]
      start += 1


    # while start < midpoint
    #   #newArr.push []
    #   hv = if arr.length % 2 is 1 then highCounter + 1 else highCounter
    #   if arr[start] and arr[hv]
    #     #newArr[newArr.length - 1].push arr[start]
    #     #newArr[newArr.length - 1].push arr[hv]
    #     newArr.push arr[start]
    #     newArr.push arr[hv]
    #   start += 1
    #   highCounter += 1

    # if arr.length % 2 is 1
    #   newArr.push arr[start]
    
    newArr

  makeDecisionAidUserReq: (params, stateToName, slug) ->
    d = @$q.defer()
    @Auth.getDecisionAidUser(params).then((data) =>
      @Storage.setDecisionAidUserId(data.decision_aid_user.id)
      @decision_aid_user = data.decision_aid_user

      @unfilteredPages =  @_.toArray data.meta.pages
      filteredPages = @_.filter(data.meta.pages, (p) -> !p.skipped)
      @_.each filteredPages, (p, i) ->
        p.page_index = i
      @allPages = @_.toArray(filteredPages)
      @pages = @chunk(@_.sortBy(filteredPages, 'page_index'))
      #@pages = @_.flatten(@pages)
      #console.log @pages
      #@pages = @_.sortBy(data.meta.pages, 'page_index')
      @indexedPages = @_.indexBy filteredPages, 'page_name'
      @pageIndexedPages = @_.indexBy filteredPages, 'page_index'
      
      #@$stateParams.pid = null
      #@$stateParams.uuid = null
      #@$stateParams.access_password = null

      @_.each @extra_params, (p, k) =>
        @$location.search(k, null)

      # set location extra params to null, so that we don't go into an infinite loop

      #console.log params
      #console.log stateToName 

      stateNameAccessor = stateToName.replace("decisionAid", "")
      # if the user has permission to visit the page stateNameAccessor
      if @indexedPages[stateNameAccessor] and @indexedPages[stateNameAccessor].available
        # go to that page
        @$state.go "#{stateToName}", {slug: slug}, {reload: true}
      else if params.static_page_slug and stateNameAccessor is "StaticPage"
        @$state.go "#{stateToName}", {slug: slug, static_page_slug: params.static_page_slug}, {reload: true}
      else
        # else go to the intro page
        @$state.go "decisionAidIntro", {slug: slug}, {reload: true}
      d.resolve(data)

    , (error) =>
      # We should only get here if the decision aid is password protected
      # and the params do not contain the correct password
      if error and error.error == "PasswordProtected"

        @daError = "password_required"
        # we should open a modal that asks for a password
        @openPasswordModal(params, stateToName, slug)
      if slug isnt @$stateParams.slug
        @ngSilentLocation.silent("/decision_aid/#{slug}/intro")

      # broadcast that the decision aid is no longer valid so that
      # the child views don't render anything
      @$rootScope.$broadcast 'decisionAidInvalid'

      d.reject(error)
    )
    d.promise

  getDecisionAidUser: (params, stateToName, slug, openSessionModal=false) ->
    @$rootScope.$broadcast 'dcida.newUserRequested'
    @Storage.clearFrontEndData()
    
    if openSessionModal
      @openDecisionAidSessionModal(params).then () =>
        @makeDecisionAidUserReq(params, stateToName, slug)
    else
      @makeDecisionAidUserReq(params, stateToName, slug)

  getUser: () ->
    if !@user
      @Auth.currentUser().then(
        (user) =>
          @user = user
       ,(error) =>
        @user = null
        @$state.go 'signin'
      )

module.controller 'NavCtrl', NavCtrl

