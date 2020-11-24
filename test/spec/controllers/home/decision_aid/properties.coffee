'use strict'

mockPropertiesPageBasic = {
  "decision_aid": {
    "id": 4,
    "title": "Colorectal Cancer Screening",
    "slug": "clrcs",
    "demographic_questions_count": 3,
    "quiz_questions_count": 3,
    "minimum_property_count": 3,
    "decision_aid_type": "standard",
    "properties": [
      {
        "id": 1,
        "title": "Property 1",
        "property_order": 1,
        "short_label": "Property 1 short label",
        "injected_selection_about_published": "Property 1 selection about published",
        "injected_long_about_published": "Property 1 long about published"
      },
      {
        "id": 2,
        "title": "Property 2",
        "property_order": 2,
        "short_label": "Property 2 short label",
        "injected_selection_about_published": "Property 2 selection about published",
        "injected_long_about_published": "Property 2 long about published"
      },
      {
        "id": 3,
        "title": "Property 3",
        "property_order": 3,
        "short_label": "Property 3 short label",
        "injected_selection_about_published": "Property 3 selection about published",
        "injected_long_about_published": "Property 3 long about published"
      },
      {
        "id": 4,
        "title": "Property 4",
        "property_order": 4,
        "short_label": "Property 4 short label",
        "injected_selection_about_published": "Property 4 selection about published",
        "injected_long_about_published": "Property 4 long about published"
      },
      {
        "id": 5,
        "title": "Property 5",
        "property_order": 5,
        "short_label": "Property 5 short label",
        "injected_selection_about_published": "Property 5 selection about published",
        "injected_long_about_published": "Property 5 long about published"
      },
    ]
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
      "properties": {
        "available": true,
        "completed": true,
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

describe 'Controller: DecisionAidPropertiesCtrl: ', ->
  beforeEach () ->
    angular.mock.module('dcida20App')
    angular.mock.module('dcida20AppMock')

  DecisionAidPropertiesCtrl = {}
  rootScope = {}
  httpBackend = {}
  MockStateService = {}
  MockConfirmService = {}

  controllerParams = {}
  decisionAidFoundCalled = false

  beforeEach inject ($injector, $rootScope, ___, _$q_, _MockNavBroadcastService_, _MockStateService_, _MockConfirmService_) ->
    rootScope = $rootScope
    scope = $rootScope.$new()
    MockStateService = _MockStateService_
    MockConfirmService = _MockConfirmService_

    httpBackend = $injector.get('$httpBackend')

    controllerParams = {
      $scope: scope,
      $stateParams: {decisionAidSlug: "clrcs"},
      $q: _$q_,
      _: ___,
      NavBroadcastService: _MockNavBroadcastService_,
      $state: MockStateService,
      Confirm: MockConfirmService
    }

  describe "Basic mocks: ", () ->

    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockPropertiesPageBasic = angular.copy mockPropertiesPageBasic
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/properties').respond(_mockPropertiesPageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/1/decision_aid_user_properties").respond([])
      httpBackend.whenPOST("http://localhost:3000/api/decision_aid_users/#{mockPropertiesPageBasic.meta.decision_aid_user.id}/decision_aid_user_properties/update_selections").respond([])

      DecisionAidPropertiesCtrl = $controller 'DecisionAidPropertiesCtrl', controllerParams

      httpBackend.flush()
      
    it "should correctly set the loading variable", () ->
      expect(DecisionAidPropertiesCtrl.loading).toBeFalsy()

    it "should set some variables for the view", () ->
      expect(DecisionAidPropertiesCtrl.decisionAid).toBeDefined()
      expect(DecisionAidPropertiesCtrl.properties).toBeDefined()
      expect(DecisionAidPropertiesCtrl.propertiesHash).toBeDefined()
      expect(DecisionAidPropertiesCtrl.properties.length).toBeGreaterThan(0)

    it "should increase properties length", () ->
      expect(DecisionAidPropertiesCtrl.checkPropertiesLength()).toBe(0)
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      expect(DecisionAidPropertiesCtrl.checkPropertiesLength()).toBe(1)

    it "should decrease properties length if same property selected again", () ->
      expect(DecisionAidPropertiesCtrl.checkPropertiesLength()).toBe(0)
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      expect(DecisionAidPropertiesCtrl.checkPropertiesLength()).toBe(1)
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      expect(DecisionAidPropertiesCtrl.checkPropertiesLength()).toBe(0)

    it "should set correct bools when decisionAidInvalid event is received", () ->
      rootScope.$broadcast 'decisionAidInvalid'

      expect(DecisionAidPropertiesCtrl.loading).toBeFalsy()
      expect(DecisionAidPropertiesCtrl.decisionAid).toBeNull()
      expect(DecisionAidPropertiesCtrl.noDecisionAidFound).toBeTruthy()

    it "should return an array of ordered properties when orderedUserProperties is called", () ->
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[2])
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[1])
      expect(DecisionAidPropertiesCtrl.checkPropertiesLength()).toBe(3)
      result = DecisionAidPropertiesCtrl.orderedUserProperties()
      expect(result[0].property_id).toBe(DecisionAidPropertiesCtrl.properties[0].id)
      expect(result[1].property_id).toBe(DecisionAidPropertiesCtrl.properties[2].id)
      expect(result[2].property_id).toBe(DecisionAidPropertiesCtrl.properties[1].id)

    it "should return the number of remaining properties when remainingProperties is called", () ->
      initialRemaining = DecisionAidPropertiesCtrl.decisionAid.minimum_property_count
      expect(DecisionAidPropertiesCtrl.remainingProperties()).toBe(initialRemaining)
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      expect(DecisionAidPropertiesCtrl.remainingProperties()).toBe(initialRemaining-1)
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[2])
      expect(DecisionAidPropertiesCtrl.remainingProperties()).toBe(initialRemaining-2)
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      expect(DecisionAidPropertiesCtrl.remainingProperties()).toBe(initialRemaining-1)

    it "should show a modal when the minimum_property_count is met", () ->
      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[0])
      rootScope.$digest()
      expect(DecisionAidPropertiesCtrl.hasScrolled).toBeFalsy()

      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[1])
      rootScope.$digest()
      expect(DecisionAidPropertiesCtrl.hasScrolled).toBeFalsy()

      DecisionAidPropertiesCtrl.selectProperty(DecisionAidPropertiesCtrl.properties[2])
      rootScope.$digest()
      expect(DecisionAidPropertiesCtrl.hasScrolled).toBeTruthy()

    it "should return null from remainingProperties if there is no decision aid defined", () ->
      DecisionAidPropertiesCtrl.decisionAid = null
      expect(DecisionAidPropertiesCtrl.remainingProperties()).toBeNull()

    describe "navigation (forward)", () ->
      it "should navigate to results page if demographic_questions_count > 0 and current intro page is last page", () ->
        DecisionAidPropertiesCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidResults")

      it "should navigate to the quiz page if decision aid type is 'best_worst_with_prefs_after_choice' and quiz_questions_count > 0", () ->
        # pretend type is best_worst_with_prefs_after_choice
        DecisionAidPropertiesCtrl.decisionAid.decision_aid_type = "best_worst_with_prefs_after_choice"
        DecisionAidPropertiesCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidQuiz")

      it "should navigate to the summary page if decision aid type is 'best_worst_with_prefs_after_choice' and quiz_questions_count == 0", () ->
        # pretend quiz_questions_count = 0
        DecisionAidPropertiesCtrl.decisionAid.quiz_questions_count = 0
        # pretend type is best_worst_with_prefs_after_choice
        DecisionAidPropertiesCtrl.decisionAid.decision_aid_type = "best_worst_with_prefs_after_choice"
        DecisionAidPropertiesCtrl.submitNext()
        httpBackend.flush()
        expect(MockStateService.target).toBe("decisionAidSummary")

    describe "navigation (backward)", () ->
      it "should go back to about page in default case if demographic_questions_count > 0", () ->
        DecisionAidPropertiesCtrl.prevLink()
        expect(MockStateService.target).toBe("decisionAidAbout")

      it "should go back to intro page in default case if demographic_questions_count == 0", () ->
        # pretend demographic_questions_count = 0
        DecisionAidPropertiesCtrl.decisionAid.demographic_questions_count = 0
        DecisionAidPropertiesCtrl.prevLink()
        expect(MockStateService.target).toBe("decisionAidIntro")

      it "should go back to results page if decision aid type is 'best_worst_with_prefs_after_choice", () ->
        DecisionAidPropertiesCtrl.decisionAid.decision_aid_type = "best_worst_with_prefs_after_choice"
        DecisionAidPropertiesCtrl.prevLink()
        expect(MockStateService.target).toBe("decisionAidResults")

  describe "With bad request to get decision aid", ( )->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/properties').respond(400)

      DecisionAidPropertiesCtrl = $controller 'DecisionAidPropertiesCtrl', controllerParams

      httpBackend.flush()

    it "Should set correct bools on error", () ->
      expect(DecisionAidPropertiesCtrl.loading).toBeFalsy()
      expect(DecisionAidPropertiesCtrl.decisionAid).toBeNull()
      expect(DecisionAidPropertiesCtrl.noDecisionAidFound).toBeTruthy()

  describe "With bad request to get basic page submissions", ( )->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockPropertiesPageBasic = angular.copy mockPropertiesPageBasic
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/properties').respond(_mockPropertiesPageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/1/decision_aid_user_properties").respond(400)

      DecisionAidPropertiesCtrl = $controller 'DecisionAidPropertiesCtrl', controllerParams

      httpBackend.flush()

    it "Should set correct bools on error", () ->
      expect(DecisionAidPropertiesCtrl.loading).toBeFalsy()
      expect(DecisionAidPropertiesCtrl.decisionAid).toBeNull()
      expect(DecisionAidPropertiesCtrl.noDecisionAidFound).toBeTruthy()

