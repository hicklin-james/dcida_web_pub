'use strict'

mockIntroPageBasic = {
  "decision_aid": {
    "id": 4,
    "title": "Colorectal Cancer Screening",
    "slug": "clrcs",
    "demographic_questions_count": 2,
    "intro_pages_count": 1,
    "decision_aid_type": "standard",
    "injected_intro_popup_information_published": null,
    "has_intro_popup": false,
    "intro_page": {
      "id": 4,
      "injected_description_published": "Published intro information"
      "intro_page_order": 1
    }
  },
  "meta": {
    "pages": {
      "intro": {
        "available": true,
        "completed": true,
        "page_title": "Introduction",
        "page_name": "Intro",
        "page_params": null,
        "page_index": 0
      },
      "about": {
        "available": true,
        "completed": false,
        "page_title": "About Me",
        "page_name": "About",
        "page_params": null,
        "page_index": 1
      },
      "properties": {
        "available": false,
        "completed": false,
        "page_title": "My Values",
        "page_name": "Properties",
        "page_params": null,
        "page_index": 2
      },
      "results_1": {
        "available": false,
        "completed": false,
        "page_title": "My Choice",
        "page_name": "Results",
        "page_params": {
          "sub_decision_order": 1
        },
        "page_index": 3
      },
      "quiz": {
        "available": false,
        "completed": false,
        "page_title": "Review",
        "page_name": "Quiz",
        "page_params": null,
        "page_index": 4
      },
      "summary": {
        "available": false,
        "completed": false,
        "page_title": "Summary",
        "page_name": "Summary",
        "page_params": null,
        "page_index": 5
      }
    },
    "decision_aid_user": {
      "id": 1,
      "decision_aid_id": 4,
      "about_me_complete": false,
      "decision_aid_user_properties_count": 0,
      "quiz_complete": false,
      "selected_option_id": null,
      "uuid": "18ed35c6-f7fe-4117-ac71-49ca20e6c094",
      "pid": null,
      "created_at": "2017-10-20T01:44:54.683Z",
      "updated_at": "2017-10-20T01:44:54.683Z",
      "decision_aid_user_responses_count": 0,
      "decision_aid_user_option_properties_count": 0,
      "decision_aid_user_dce_question_set_responses_count": 0,
      "decision_aid_user_bw_question_set_responses_count": 0,
      "decision_aid_user_sub_decision_choices_count": 0
    },
    "is_new_user": false
  }
}

mockBasicPageSubmission = {
  id: 1,
  intro_page_id: 4,
  decision_aid_user_id: 1
}

describe 'Controller: DecisionAidIntroCtrl: ', ->
  beforeEach () ->
    angular.mock.module('dcida20App')
    angular.mock.module('dcida20AppMock')

  DecisionAidIntroCtrl = {}
  rootScope = {}
  httpBackend = {}
  MockUibModalService = {}
  MockStateService = {}

  controllerParams = {}
  decisionAidFoundCalled = false

  beforeEach inject ($injector, $rootScope, ___, _$q_, _MockNavBroadcastService_, _MockUibModalService_, _MockStateService_) ->
    rootScope = $rootScope
    scope = $rootScope.$new()
    MockUibModalService = _MockUibModalService_
    MockStateService = _MockStateService_

    httpBackend = $injector.get('$httpBackend')

    controllerParams = {
      $scope: scope,
      $stateParams: {decisionAidSlug: "clrcs"},
      $q: _$q_,
      _: ___,
      NavBroadcastService: _MockNavBroadcastService_,
      $uibModal: MockUibModalService,
      $state: MockStateService
    }

  describe "Basic mocks: ", () ->

    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockIntroPageBasic = angular.copy mockIntroPageBasic
      _mockBasicPageSubmission = angular.copy mockBasicPageSubmission
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/intro?first=true').respond(_mockIntroPageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/1/basic_page_submissions?intro_page_id=#{mockIntroPageBasic.decision_aid.intro_page.id}").respond([])
      httpBackend.whenPOST("http://localhost:3000/api/decision_aid_users/#{mockIntroPageBasic.meta.decision_aid_user.id}/basic_page_submissions").respond(_mockBasicPageSubmission)

      DecisionAidIntroCtrl = $controller 'DecisionAidIntroCtrl', controllerParams

      httpBackend.flush()

    it "should correctly set the loading variable", () ->
      expect(DecisionAidIntroCtrl.loading).toBeFalsy()

    it "should have no basicPageSubmission set", () ->
      expect(DecisionAidIntroCtrl.basicPageSubmission).not.toBeDefined()

    it "should save a new basic page submission when saveIfNewPageSubmission is called", () ->
      DecisionAidIntroCtrl.saveIfNewPageSubmission()
      httpBackend.flush()
      expect(DecisionAidIntroCtrl.basicPageSubmission).toBeDefined()

    it "should not open the intro modal", () ->
      expect(MockUibModalService.modalOpened).toBeFalsy()

    it "should define some variables for the view", () ->
      expect(DecisionAidIntroCtrl.decisionAid).toEqual(mockIntroPageBasic.decision_aid)
      expect(DecisionAidIntroCtrl.currentPage).toEqual(mockIntroPageBasic.decision_aid.intro_page)

    it "should set correct bools when decisionAidInvalid event is received", () ->
      rootScope.$broadcast 'decisionAidInvalid'

      expect(DecisionAidIntroCtrl.loading).toBeFalsy()
      expect(DecisionAidIntroCtrl.decisionAid).toBeNull()
      expect(DecisionAidIntroCtrl.noDecisionAidFound).toBeTruthy()

    describe "navigation (forward)", () ->
      it "should navigate to about page if demographic_questions_count > 0 and current intro page is last page", () ->
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidAbout")

      it "should navigate to properties page if there are no demographic questions and current intro page is last page", () ->
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidProperties")

      it "should navigate to next intro page if current intro page is not last page", () ->
        # pretend there are 2 intro pages
        DecisionAidIntroCtrl.decisionAid.intro_pages_count = 2
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidIntro")
        expect(MockStateService.params.curr_intro_page_order).toBe(2)

      it "should navigate to DCE page if decision aid type is 'dce' and there are no demographic questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        # pretend type is dce
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "dce"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidDce")

      it "should navigate to DCE page if decision aid type is 'dce_no_results' and there are no demographic questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        # pretend type is dce_no_results
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "dce_no_results"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidDce")

      it "should navigate to best/worst page if decision aid type is 'best_worst' and there are no demographic questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        # pretend type is best_worst
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "best_worst"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidBestWorst")

      it "should navigate to best/worst page if decision aid type is 'best_worst_no_results' and there are no demographic questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        # pretend type is best_worst_no_results
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "best_worst_no_results"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidBestWorst")

      it "should navigate to results page if decision aid type is 'traditional' and there are no demographic questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        # pretend type is traditional
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "traditional"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidResults")

      it "should navigate to properties (enhanced view) if decision aid type is 'standard_enhanced' and there are no demographic questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        # pretend type is standard_enhanced
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "standard_enhanced"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidPropertiesEnhanced")

      it "should navigate to quiz if decision aid type is 'risk_calculator' and there are no demographic questions and there are some quiz questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        DecisionAidIntroCtrl.decisionAid.quiz_questions_count = 1
        # pretend type is risk_calculator
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "risk_calculator"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidQuiz")

      it "should navigate to summary if decision aid type is 'risk_calculator' and there are no demographic questions and there are no quiz questions", () ->
        # pretend there are no demographic questions
        DecisionAidIntroCtrl.decisionAid.demographic_questions_count = 0
        DecisionAidIntroCtrl.decisionAid.quiz_questions_count = 0
        # pretend type is risk_calculator
        DecisionAidIntroCtrl.decisionAid.decision_aid_type = "risk_calculator"
        DecisionAidIntroCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidSummary")

    describe 'navigation (backward)', () ->
      it 'should navigate back one intro page if the prev button is pushed and we are not at the first intro page', () ->
        DecisionAidIntroCtrl.currentPage.intro_page_order = 2
        DecisionAidIntroCtrl.prevLink()
        expect(MockStateService.target).toBe("decisionAidIntro")
        expect(MockStateService.params.curr_intro_page_order).toBe(1)

  describe "With intro popup: ", () ->

    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockIntroPageBasic = angular.copy mockIntroPageBasic
      _mockIntroPageBasic.decision_aid.has_intro_popup = true
      _mockBasicPageSubmission = angular.copy mockBasicPageSubmission
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/intro?first=true').respond(_mockIntroPageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/1/basic_page_submissions?intro_page_id=#{mockIntroPageBasic.decision_aid.intro_page.id}").respond([])

      DecisionAidIntroCtrl = $controller 'DecisionAidIntroCtrl', controllerParams

      httpBackend.flush()
 
    it "should open the intro modal", () ->
      expect(MockUibModalService.modalOpened).toBeTruthy()

    it "should dismiss the modal when the state starts to change", () ->
      expect(MockUibModalService.modalOpened).toBeTruthy()
      rootScope.$broadcast '$stateChangeStart'
      expect(MockUibModalService.modalOpened).toBeFalsy()

  describe "With invalid current page", () ->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockIntroPageBasic = angular.copy mockIntroPageBasic
      _mockIntroPageBasic.decision_aid.intro_page = null
      _mockBasicPageSubmission = angular.copy mockBasicPageSubmission
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/intro?first=true').respond(_mockIntroPageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/1/basic_page_submissions?intro_page_id=#{mockIntroPageBasic.decision_aid.intro_page.id}").respond([])

      DecisionAidIntroCtrl = $controller 'DecisionAidIntroCtrl', controllerParams

      httpBackend.flush()

    it "Should redirect to the first intro page", () ->
      expect(MockStateService.target).toBe("decisionAidIntro")
      expect(MockStateService.params.first).toBeTruthy()

  describe "With bad request to get decision aid", ( )->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/intro?first=true').respond(400)

      DecisionAidIntroCtrl = $controller 'DecisionAidIntroCtrl', controllerParams

      httpBackend.flush()

    it "Should set correct bools on error", () ->
      expect(DecisionAidIntroCtrl.loading).toBeFalsy()
      expect(DecisionAidIntroCtrl.decisionAid).toBeNull()
      expect(DecisionAidIntroCtrl.noDecisionAidFound).toBeTruthy()

  describe "With bad request to get basic page submissions", ( )->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockIntroPageBasic = angular.copy mockIntroPageBasic
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/intro?first=true').respond(_mockIntroPageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/1/basic_page_submissions?intro_page_id=#{mockIntroPageBasic.decision_aid.intro_page.id}").respond(400)

      DecisionAidIntroCtrl = $controller 'DecisionAidIntroCtrl', controllerParams

      httpBackend.flush()

    it "Should set correct bools on error", () ->
      expect(DecisionAidIntroCtrl.loading).toBeFalsy()
      expect(DecisionAidIntroCtrl.decisionAid).toBeNull()
      expect(DecisionAidIntroCtrl.noDecisionAidFound).toBeTruthy()