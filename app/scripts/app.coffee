###*
 # @ngdoc overview
 # @name dcida20App
 # @description
 # # dcida20App
 #
 # Main module of the application.
###

angular.module('underscore', [])
  .factory '_', ->
    underscore = window._
    underscore.mixin underscore.str.exports()
    underscore

angular
  .module 'dcida20App', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngSanitize',
    'ngTouch',
    'ui.router'
    'dcida20App.config',
    'dcida20App.translations',
    'underscore',
    'ui.bootstrap',
    'angularMoment',
    'angular-redactor',
    'ngFileUpload',
    'ncy-angular-breadcrumb',
    'http-auth-interceptor',
    'highcharts-ng',
    'ui.slider',
    'duScroll',
    'ng-slide-down',
    'angular-intro',
    'angular-bind-html-compile',
    'ngDragDrop',
    'angular-sortable-view',
    'colorpicker.module',
    'ui.select',
    'vs-repeat',
    'as.sortable',
    'ngSilent',
    'uiCropper',
    'angularSlideables',
    'pascalprecht.translate',
    'ui.carousel',
    'globalConfig.sharedConfig'
  ]         
  .config ['$stateProvider', '$urlRouterProvider', 'redactorOptions', 'API_ENDPOINT', '$compileProvider', '$httpProvider', '$translateProvider', '$uiViewScrollProvider', 'TRANSLATIONS', 'SUPPORTED_LANGUAGES', ($stateProvider, $urlRouterProvider, redactorOptions, API_ENDPOINT, $compileProvider, $httpProvider, $translateProvider, $uiViewScrollProvider, TRANSLATIONS, SUPPORTED_LANGUAGES) ->

    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|file):/);

    $httpProvider.interceptors.push(($q) =>
      return {
        'request': (config) =>
          # do something for all requests here
          return config
      }
    )

    # setup translations
    for lang in SUPPORTED_LANGUAGES
      translationTable = {}
      for key of TRANSLATIONS
        if TRANSLATIONS[key][lang]
          translationTable[key] = TRANSLATIONS[key][lang]

      $translateProvider.translations(lang, translationTable)
      $translateProvider.useSanitizeValueStrategy('escape')

    $uiViewScrollProvider.useAnchorScroll();

    $translateProvider.preferredLanguage('en')

    $urlRouterProvider.rule ($injector, $location) =>
      path = $location.path()
      if path[path.length-1] is '/'
        newPath = path.substr(0, path.length - 1);
        return newPath

    $stateProvider
      .state 'signin',
        url: '/signin'
        templateUrl: 'views/admin/signin.html'
        controller: 'SigninCtrl'
        data:
          signin: true
        ncyBreadcrumb: {
          skip: true
        }

    $stateProvider
      .state 'rootWithSlash',
        url: '/'
        templateUrl: 'views/admin/signin.html'
        controller: 'SigninCtrl'
        data:
          signin: true
        ncyBreadcrumb: {
          skip: true
        }

    $stateProvider
      .state 'root',
        url: ''
        templateUrl: 'views/admin/signin.html'
        controller: 'SigninCtrl'
        data:
          signin: true
        ncyBreadcrumb: {
          skip: true
        }

    $stateProvider
      .state 'userList',
        url: '/admin/users'
        templateUrl: 'views/admin/user/list.html'
        controller: 'UserListCtrl',
        ncyBreadcrumb: {
          label: 'Users'
        },
        data:
          admin: true

    $stateProvider
      .state 'userNew',
        url: '/admin/users/new'
        templateUrl: 'views/admin/user/new.html'
        controller: 'UserNewCtrl',
        ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'userList'
        },
        data:
          admin: true

    $stateProvider
      .state 'userCreate',
        url: '/user_create?createToken&email'
        templateUrl: 'views/admin/user/create.html'
        controller: 'UserCreateCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          signin: true

    $stateProvider
      .state 'resetPasswordRequest',
        url: '/reset_password_request'
        templateUrl: 'views/admin/reset_password_request.html'
        controller: 'ResetPasswordRequestCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          signin: true

    $stateProvider
      .state 'resetPassword',
        url: '/user_reset?resetToken&email'
        templateUrl: 'views/admin/user/password_reset.html'
        controller: 'ResetPasswordCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          signin: true

    $stateProvider
      .state 'userEdit',
        url: '/admin/users/{userId:[-0-9]+}/edit'
        templateUrl: 'views/admin/user/edit.html'
        controller: 'UserEditCtrl',
        ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'userList'
        },
        data:
          admin: true

    $stateProvider
      .state 'decisionAidList',
        url: '/admin/decision_aids'
        templateUrl: 'views/admin/decision_aid/list.html'
        controller: 'DecisionAidListCtrl',
        ncyBreadcrumb: {
          label: 'Decision Aids'
        },
        data:
          admin: true



    # $stateProvider
    #   .state 'decisionAidEdit',
    #     url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/edit'
    #     templateUrl: 'views/admin/decision_aid/edit.html'
    #     controller: 'DecisionAidEditCtrl',
    #     ncyBreadcrumb: {
    #       label: '{{ctrl.title}}'
    #       parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
    #     },
    #     data:
    #       admin: true

    # $stateProvider
    #   .state 'decisionAidStyle',
    #     url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/style'
    #     templateUrl: 'views/admin/decision_aid/style.html'
    #     controller: 'DecisionAidStyleCtrl',
    #     ncyBreadcrumb: {
    #       label: '{{ctrl.title}}'
    #       parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
    #     },
    #     data:
    #       admin: true

    $stateProvider
      .state 'decisionAidShow',
        url: '/admin/decision_aids/{decisionAidId:[-0-9]+}'
        templateUrl: 'views/admin/decision_aid/show.html'
        controller: 'DecisionAidShowCtrl'
        ncyBreadcrumb: {
          label: '{{ctrl.$stateParams.decisionAidId}}'
          parent: 'decisionAidList'
        },
        data:
          admin: true

    # $stateProvider
    #   .state 'decisionAidShow.optionPropertyMatrix',
    #     url: '/optionPropertyMatrix'
    #     templateUrl: 'views/admin/decision_aid/option_property_matrix.html'
    #     controller: 'DecisionAidOptionPropertyMatrixCtrl',
    #     ncyBreadcrumb: {
    #       skip: true
    #     },
    #     data:
    #       admin: true
    #       stateName: "optionPropertyMatrix"

    $stateProvider
      .state 'decisionAidShow.instructions',
        url: '/instructions'
        templateUrl: 'views/admin/decision_aid/edit/instructions.html'
        controller: 'DecisionAidEditInstructionsCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "instructions"

    $stateProvider
      .state 'decisionAidShow.basic',
        url: '/basic'
        templateUrl: 'views/admin/decision_aid/edit/basic.html'
        controller: 'DecisionAidEditBasicCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "basic"

    $stateProvider
      .state 'decisionAidShow.staticPages',
        url: '/static_pages'
        templateUrl: 'views/admin/decision_aid/edit/static_pages.html'
        controller: 'DecisionAidEditStaticPagesCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "staticPages"

    $stateProvider
      .state 'decisionAidShow.advanced',
        url: '/advanced'
        templateUrl: 'views/admin/decision_aid/edit/advanced.html'
        controller: 'DecisionAidEditAdvancedCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "advanced"

    $stateProvider
      .state 'decisionAidShow.style',
        url: '/style'
        templateUrl: 'views/admin/decision_aid/edit/style.html'
        controller: 'DecisionAidEditStyleCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "style"

    $stateProvider
      .state 'decisionAidShow.introduction',
        url: '/introduction'
        templateUrl: 'views/admin/decision_aid/edit/introduction.html'
        controller: 'DecisionAidEditIntroductionCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "introduction"

    $stateProvider
      .state 'decisionAidShow.aboutMe',
        url: '/aboutMe'
        templateUrl: 'views/admin/decision_aid/edit/about_me.html'
        controller: 'DecisionAidEditAboutMeCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "aboutMe"

    $stateProvider
      .state 'decisionAidShow.myOptions',
        url: '/myOptions'
        templateUrl: 'views/admin/decision_aid/edit/my_options.html'
        controller: 'DecisionAidEditMyOptionsCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "myOptions"

    $stateProvider
      .state 'decisionAidShow.propertiesNoResults',
        url: '/propertiesNoResults'
        templateUrl: 'views/admin/decision_aid/edit/properties_no_results.html'
        controller: 'DecisionAidEditMyOptionsCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "propertiesNoResults"

    $stateProvider
      .state 'decisionAidShow.myProperties',
        url: '/myProperties'
        templateUrl: 'views/admin/decision_aid/edit/my_properties.html'
        controller: 'DecisionAidEditMyPropertiesCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "myProperties"

    $stateProvider
      .state 'decisionAidShow.dce',
        url: '/dce'
        templateUrl: 'views/admin/decision_aid/edit/dce.html'
        controller: 'DecisionAidEditDceCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "dce"

    $stateProvider
      .state 'decisionAidShow.bestWorst',
        url: '/bestWorst'
        templateUrl: 'views/admin/decision_aid/edit/best_worst.html'
        controller: 'DecisionAidEditBestWorstCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "bestWorst"

    $stateProvider
      .state 'decisionAidShow.myChoice',
        url: '/myChoice'
        templateUrl: 'views/admin/decision_aid/edit/my_choice.html'
        controller: 'DecisionAidEditMyChoiceCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "myChoice"

    $stateProvider
      .state 'decisionAidShow.quiz',
        url: '/quiz'
        templateUrl: 'views/admin/decision_aid/edit/quiz.html'
        controller: 'DecisionAidEditQuizCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "quiz"

    $stateProvider
      .state 'decisionAidShow.summary',
        url: '/summary'
        templateUrl: 'views/admin/decision_aid/edit/summary.html'
        controller: 'DecisionAidEditSummaryCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "summary"

    $stateProvider
      .state 'decisionAidShow.dataTargets',
        url: '/dataTargets'
        templateUrl: 'views/admin/decision_aid/edit/data_targets.html'
        controller: 'DecisionAidEditDataTargetsCtrl',
        ncyBreadcrumb: {
          skip: true
        },
        data:
          admin: true
          stateName: "dataTargets"

    $stateProvider
      .state 'decisionAidNew',
        url: '/admin/decision_aids/new'
        templateUrl: 'views/admin/decision_aid/edit.html'
        controller: 'DecisionAidNewCtrl'
        ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidList'
        },
        data:
          admin: true

    $stateProvider
      .state 'optionEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/options/{id:[-0-9]+}/edit?{sub_decision_id:[-0-9]+}'
       templateUrl: 'views/admin/decision_aid/option/edit.html'
       controller: 'OptionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'optionNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/options/new?{sub_decision_id:[-0-9]+}'
       templateUrl: 'views/admin/decision_aid/option/edit.html'
       controller: 'OptionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'propertyEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/properties/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/property/edit.html'
       controller: 'PropertyEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'propertyNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/properties/new'
       templateUrl: 'views/admin/decision_aid/property/edit.html'
       controller: 'PropertyEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'dataTargetEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/data_targets/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/data_target/edit.html'
       controller: 'DataTargetEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'dataTargetNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/data_targets/new'
       templateUrl: 'views/admin/decision_aid/data_target/edit.html'
       controller: 'DataTargetEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'staticPageEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/static_pages/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/static_page/edit.html'
       controller: 'StaticPageEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'staticPageNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/static_pages/new'
       templateUrl: 'views/admin/decision_aid/static_page/edit.html'
       controller: 'StaticPageEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'optionPropertyEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/properties/{propertyId:[-0-9]+}/options/{optionId:[-0-9]+}/option_properties/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/option_property/edit.html'
       controller: 'OptionPropertyEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'optionPropertyMultiEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/properties/{propertyId:[-0-9]+}/options/{optionId:[-0-9]+}/option_properties/edit'
       templateUrl: 'views/admin/decision_aid/option_property/edit.html'
       controller: 'OptionPropertyEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'optionPropertyNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/properties/{propertyId:[-0-9]+}/options/{optionId:[-0-9]+}/option_properties/new'
       templateUrl: 'views/admin/decision_aid/option_property/edit.html'
       controller: 'OptionPropertyEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'subDecisionNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/sub_decisions/new'
       templateUrl: 'views/admin/decision_aid/sub_decision/edit.html'
       controller: 'SubDecisionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'subDecisionEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/sub_decisions/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/sub_decision/edit.html'
       controller: 'SubDecisionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'questionEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/question_pages/{questionPageId:[-0-9]+}/questions/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/question/edit.html'
       controller: 'QuestionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'questionNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/question_pages/{questionPageId:[-0-9]+}/questions/new'
       templateUrl: 'views/admin/decision_aid/question/edit.html'
       controller: 'QuestionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       params:
        questionType: null
       data:
        admin: true

    $stateProvider
      .state 'questionEditHidden',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/questions/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/question/edit.html'
       controller: 'QuestionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'questionNewHidden',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/questions/new'
       templateUrl: 'views/admin/decision_aid/question/edit.html'
       controller: 'QuestionEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       params:
        questionType: null
       data:
        admin: true

    $stateProvider
      .state 'summaryPanelEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/summary_pages/{summary_page_id:[-0-9]+}/summary_panels/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/summary_panel/edit.html'
       controller: 'SummaryPanelEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'summaryPanelNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/summary_pages/{summary_page_id:[-0-9]+}/summary_panels/new'
       templateUrl: 'views/admin/decision_aid/summary_panel/edit.html'
       controller: 'SummaryPanelEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'introPageEdit',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/intro_pages/{id:[-0-9]+}/edit'
       templateUrl: 'views/admin/decision_aid/intro_page/edit.html'
       controller: 'IntroPageEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    $stateProvider
      .state 'introPageNew',
       url: '/admin/decision_aids/{decisionAidId:[-0-9]+}/intro_pages/new'
       templateUrl: 'views/admin/decision_aid/intro_page/edit.html'
       controller: 'IntroPageEditCtrl'
       ncyBreadcrumb: {
          label: '{{ctrl.title}}'
          parent: 'decisionAidShow({decisionAidId: ctrl.$stateParams.decisionAidId})'
        },
       data:
        admin: true

    ### Front end states ###
    $stateProvider
      .state 'decisionAidIntroDefault',
        url: '/decision_aid/{slug}?access_password&curr_intro_page_order&first&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/intro.html'
        controller: 'DecisionAidIntroCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidIntro',
        url: '/decision_aid/{slug}/intro?access_password&curr_intro_page_order&first&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/intro.html'
        controller: 'DecisionAidIntroCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidAbout',
        url: '/decision_aid/{slug}/about?access_password&curr_question_page_id&first&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/about.html'
        controller: 'DecisionAidAboutCtrl'
        data:
          decisionAid: true
          questionType: "demographic"

    $stateProvider
      .state 'decisionAidOptions',
        url: '/decision_aid/{slug}/options?{sub_decision_order:[-0-9]+}&access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/options.html'
        controller: 'DecisionAidOptionsCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidProperties',
        url: '/decision_aid/{slug}/properties?access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/properties.html'
        controller: 'DecisionAidPropertiesCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidPropertiesEnhanced',
        url: '/decision_aid/{slug}/properties_enhanced?access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/properties_enhanced.html'
        controller: 'DecisionAidPropertiesEnhancedCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidPropertiesDecide',
        url: '/decision_aid/{slug}/properties_decide?access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/properties_decide.html'
        controller: 'DecisionAidPropertiesDecideCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidPropertiesPostBestWorst',
        url: '/decision_aid/{slug}/properties_post_best_worst?access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/properties_post_best_worst.html'
        controller: 'DecisionAidPropertiesPostBestWorstCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidTraditionalProperties',
        url: '/decision_aid/{slug}/traditional_properties?access_password&back&clear_user&skip_session_modal&property_id'
        templateUrl: 'views/home/decision_aid/traditional_properties.html'
        controller: 'DecisionAidTraditionalPropertiesCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidDce',
        url: '/decision_aid/{slug}/dce?{current_question_set:[-0-9]+}&access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/dce.html'
        controller: 'DecisionAidDceCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidBestWorst',
        url: '/decision_aid/{slug}/best_worst?{current_question_set:[-0-9]+}&access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/bw.html'
        controller: 'DecisionAidBestWorstCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidResults',
        url: '/decision_aid/{slug}/results?{sub_decision_order:[-0-9]+}&access_password&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/results.html'
        controller: 'DecisionAidResultsCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidQuiz',
        url: '/decision_aid/{slug}/quiz?access_password&curr_question_page_id&first&back&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/quiz.html'
        controller: 'DecisionAidQuizCtrl'
        data:
          decisionAid: true
          questionType: "quiz"

    $stateProvider
      .state 'decisionAidSummary',
        url: '/decision_aid/{slug}/summary?access_password&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/summary.html'
        controller: 'DecisionAidSummaryCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'decisionAidStaticPage',
        url: '/decision_aid/{slug}/static_page?static_page_slug&access_password&clear_user&skip_session_modal'
        templateUrl: 'views/home/decision_aid/static_page.html'
        controller: 'DecisionAidStaticPageCtrl'
        data:
          decisionAid: true

    $stateProvider
      .state 'unknownPage',
        url: '/unknown'
        templateUrl: 'views/unknown_url.html'

    $urlRouterProvider.otherwise('/unknown')
  ]


