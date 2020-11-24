'use strict'

angular.module('dcida20App')
  .config ['$provide', '$httpProvider', ($provide, $httpProvider) ->
    $provide.factory 'authHttpInterceptor', ['$q', '$location', '$rootScope', 'Storage', 'API_PUBLIC', ($q, $location, $rootScope, Storage, API_PUBLIC) ->
      request: (config) ->
        # this interceptor captures all HTTP requests made by the web app so they can be modified
        config.headers ?= {}

        # config.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')

        # add the access token if there is one
        if config.url.indexOf(API_PUBLIC) >= 0
          token = Storage.getAccessToken()
          if token?
            config.headers.Authorization = "Bearer #{token}"

          # add the decision aid user id if there is one
          decisionAidUserId = Storage.getDecisionAidUserId()
          if decisionAidUserId
            config.headers["DECISION-AID-USER-ID"]= decisionAidUserId

        config or $q.when config
    ]

    $httpProvider.interceptors.push 'authHttpInterceptor'
  ]
