'use strict'

angular.module('dcida20App')
  .factory 'DecisionAidHome', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->

    getLanguage: (decisionAidSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/get_language", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    staticPage: (decisionAidSlug, staticPageSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        static_page_slug: staticPageSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/static_page", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    intro: (decisionAidSlug, introPageOrder, back, first) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        curr_intro_page_order: introPageOrder
        back: back
        first: first
      $http.get("#{API_ENDPOINT}/decision_aid_home/intro", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    about: (decisionAidSlug, currQuestionPageId, back, first) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        curr_question_page_id: currQuestionPageId
        back: back
        first: first
      $http.get("#{API_ENDPOINT}/decision_aid_home/about", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    options: (decisionAidSlug, subDecisionOrder) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        sub_decision_order: subDecisionOrder
      $http.get("#{API_ENDPOINT}/decision_aid_home/options", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    properties: (decisionAidSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/properties", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    propertiesDecide: (decisionAidSlug, page=1) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        page: page
      $http.get("#{API_ENDPOINT}/decision_aid_home/properties_decide", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    propertiesEnhanced: (decisionAidSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/properties_enhanced", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    propertiesPostBestWorst: (decisionAidSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/properties_post_best_worst", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    traditionalProperties: (decisionAidSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/traditional_properties", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    bw: (decisionAidSlug, currentQuestionSet) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        current_question_set: currentQuestionSet
      $http.get("#{API_ENDPOINT}/decision_aid_home/best_worst", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    dce: (decisionAidSlug, currentQuestionSet) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        current_question_set: currentQuestionSet
      $http.get("#{API_ENDPOINT}/decision_aid_home/dce", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    results: (decisionAidSlug, subDecisionOrder) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        sub_decision_order: subDecisionOrder
      $http.get("#{API_ENDPOINT}/decision_aid_home/results", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    quiz: (decisionAidSlug, currQuestionPageId, back, first) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
        curr_question_page_id: currQuestionPageId
        back: back
        first: first
      $http.get("#{API_ENDPOINT}/decision_aid_home/quiz", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    summary: (decisionAidSlug) ->
      d = $q.defer()
      params =
        slug: decisionAidSlug
      $http.get("#{API_ENDPOINT}/decision_aid_home/summary", params: params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    openPdf: (decisionAidSlug, pageHtml, omitPid=false) ->
      d = $q.defer()
      params = 
        slug: decisionAidSlug
        html: pageHtml
        omit_pid: omitPid
      $http.post("#{API_ENDPOINT}/decision_aid_home/open_pdf", 
                 params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    generatePdf: (decisionAidSlug, pageHtml, omitPid=false, sendAddress="") ->
      d = $q.defer()
      params = 
        slug: decisionAidSlug
        html: pageHtml
        omit_pid: omitPid
        send_address: sendAddress
      $http.post("#{API_ENDPOINT}/decision_aid_home/generate_pdf", 
                 params)
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

  ]
