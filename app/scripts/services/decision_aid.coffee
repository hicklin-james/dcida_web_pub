'use strict'

###*
 # @ngdoc service
 # @name dcida20App.service:DecisionAid
 # @description
 # # DecisionAidService
 # Main DecisionAId service. Always ensure that decision aids used from the
 # server are of this type. They allow access to the typical {@link https://docs.angularjs.org/api/ngResource/service/$resource $resource} methods.
 # @example
 # <pre>
 # new(DecisionAid).$save() # POST at #{API_ENDPOINT}/decision_aids
 # DecisionAid.query (decisionAids) -> # GET at #{API_ENDPOINT}/decision_aids
 #   for decisionAid in decisionAids
 #     decisionAid.$update() # PUT at #{API_ENDPOINT}/decision_aids/#{resourceId}
 # 
 # </pre>
###

angular.module('dcida20App')
  .factory 'DecisionAid', ['$resource', '$http', '_', '$q',  'API_ENDPOINT', 'Util', ($resource, $http, _, $q, API_ENDPOINT, Util) ->
    attributes = ['description', 'slug', 'title', 'about_information', 'options_information', 
                  'properties_information', 'results_information', 'quiz_information', 'property_weight_information', 'chart_type',
                  'minimum_property_count', 'icon_id', 'footer_logos', 'ratings_enabled', 'percentages_enabled', 'best_match_enabled',
                  'decision_aid_type', 'dce_information', 'dce_specific_information', 'best_worst_information', 'best_worst_specific_information',
                  'other_options_information', 'intro_popup_information', 'has_intro_popup', 'summary_link_to_url', 'redcap_token', 'redcap_url',
                  'password_protected', 'theme', 'access_password', 'summary_email_addresses', 'best_wording', 'worst_wording',
                  'include_admin_summary_email', 'include_user_summary_email', 'user_summary_email_text', 'mysql_password', 'mysql_dbname',
                  'mysql_user', 'contact_phone_number', 'contact_email', 'include_download_pdf_button', 'more_information_button_text',
                  'final_summary_text', 'maximum_property_count', 'intro_page_label', 'about_me_page_label', 'properties_page_label', 'dce_option_prefix',
                  'results_page_label', 'quiz_page_label', 'summary_page_label', 'opt_out_information', 'properties_auto_submit', 'opt_out_label', 
                  'best_worst_page_label', 'hide_menu_bar', 'open_summary_link_in_new_tab', 'decision_aid_query_parameters_attributes',
                  'color_rows_based_on_attribute_levels', 'compare_opt_out_to_last_selected', 'use_latent_class_analysis', 'language_code',
                  'full_width', 'custom_css', 'include_dce_confirmation_question', 'dce_confirmation_question', 'dce_type', 'begin_button_text',
                  'dce_selection_label', 'dce_min_level_color', 'dce_max_level_color', 'unique_redcap_record_identifier'
                ]
    actions = Util.resourceActions 'decision_aid', 'decision_aids', attributes

    DecisionAid = $resource "#{API_ENDPOINT}/decision_aids/:id", { id: '@id' }, actions

    DecisionAid.getPages = (decision_aid_id) ->
      d = $q.defer()
      $http.get "#{API_ENDPOINT}/decision_aids/#{decision_aid_id}/page_targets"
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.preview = () ->
      d = $q.defer()
      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/preview"
        .success((data) ->
          d.resolve(data.decision_aid)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.clearUserData = () ->
      d = $q.defer()
      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/clear_user_data"
        .success((data) ->
          d.resolve(data.decision_aid)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.export = () ->
      d = $q.defer()
      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/export"
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.setupDce = (num_questions, num_responses, num_blocks, include_opt_out) ->
      d = $q.defer()
      data = 
        num_questions: num_questions
        num_responses: num_responses
        num_blocks: num_blocks
        include_opt_out: include_opt_out

      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/setup_dce", params: data
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.setupBw = (num_questions, num_attributes_per_question, num_blocks) ->
      d = $q.defer()
      data = 
        num_questions: num_questions
        num_attributes_per_question: num_attributes_per_question
        num_blocks: num_blocks

      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/setup_bw", params: data
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.downloadUserData = (data) ->
      d = $q.defer()
      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/download_user_data", params: data
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    DecisionAid.prototype.testRedcapConnection = () ->
      d = $q.defer()
      params = 
        redcap_token: @redcap_token
        redcap_url: @redcap_url
      $http.get "#{API_ENDPOINT}/decision_aids/#{@id}/test_redcap_connection", params: params
        .success((data) ->
          d.resolve(data)
        )
        .error((data) ->
          d.reject(data)
        )
      d.promise

    return DecisionAid
  ]
