'use strict'

mockDcePageBasic = {
  "decision_aid": {
    "id": 4,
    "title": "Colorectal Cancer Screening",
    "slug": "clrcs",
    "dce_type": "normal",
    "dce_question_set_title": "Question Set 1",
    "include_dce_confirmation_question": false,
    "demographic_questions_count": 3,
    "quiz_questions_count": 3,
    "dce_question_set_count": 12,
    "decision_aid_type": "dce",
    "injected_dce_information_published": "DCE general information",
    "injected_dce_specific_information_published": "DCE specific information",
    "dce_option_prefix": "Option",
    "color_rows_based_on_attribute_levels": false,
    "compare_opt_out_to_last_selected": true,
    "dce_question_set_responses": [
      {
        "id": 1,
        "decision_aid_id": 4,
        "is_opt_out": false,
        "question_set": 1,
        "response_value": 1,
        "property_level_hash": {
          1: "2", 
          2: "1", 
          3: "3", 
          4: "1", 
          5: "2",
          "orders": {
            1: "1", 
            2: "3", 
            3: "2", 
            4: "5", 
            5: "4"
          }
        }
      },
      {
        "id": 2,
        "decision_aid_id": 4,
        "is_opt_out": false,
        "question_set": 1,
        "response_value": 2,
        "property_level_hash": {
          1: "1", 
          2: "3", 
          3: "2", 
          4: "3", 
          5: "2",
          "orders": {
            1: "1", 
            2: "3", 
            3: "2", 
            4: "5", 
            5: "4"
          }
        }
      }
    ],
    "properties": [
      {
        "id": 1,
        "title": "Property 1",
        "property_order": 1,
        "short_label": "Property 1 short label",
        "injected_selection_about_published": "Property 1 selection about published",
        "injected_long_about_published": "Property 1 long about published",
        "property_levels": [
          {
            "id": 1,
            "injected_information_published": "P1L1",
            "level_id": 1,
            "property_id": 1
          },
          {
            "id": 2,
            "injected_information_published": "P1L2",
            "level_id": 2,
            "property_id": 1
          },
          {
            "id": 3,
            "injected_information_published": "P1L3",
            "level_id": 3,
            "property_id": 1
          }
        ]
      },
      {
        "id": 2,
        "title": "Property 2",
        "property_order": 2,
        "short_label": "Property 2 short label",
        "injected_selection_about_published": "Property 2 selection about published",
        "injected_long_about_published": "Property 2 long about published",
        "property_levels": [
          {
            "id": 4,
            "injected_information_published": "P2L1",
            "level_id": 1,
            "property_id": 2
          },
          {
            "id": 5,
            "injected_information_published": "P2L2",
            "level_id": 2,
            "property_id": 2
          },
          {
            "id": 6,
            "injected_information_published": "P2L3",
            "level_id": 3,
            "property_id": 2
          }
        ]
      },
      {
        "id": 3,
        "title": "Property 3",
        "property_order": 3,
        "short_label": "Property 3 short label",
        "injected_selection_about_published": "Property 3 selection about published",
        "injected_long_about_published": "Property 3 long about published",
        "property_levels": [
          {
            "id": 7,
            "injected_information_published": "P3L1",
            "level_id": 1,
            "property_id": 3
          },
          {
            "id": 8,
            "injected_information_published": "P3L2",
            "level_id": 2,
            "property_id": 3
          },
          {
            "id": 9,
            "injected_information_published": "P3L3",
            "level_id": 3,
            "property_id": 3
          }
        ]
      },
      {
        "id": 4,
        "title": "Property 4",
        "property_order": 4,
        "short_label": "Property 4 short label",
        "injected_selection_about_published": "Property 4 selection about published",
        "injected_long_about_published": "Property 4 long about published",
        "property_levels": [
          {
            "id": 10,
            "injected_information_published": "P4L1",
            "level_id": 1,
            "property_id": 4
          },
          {
            "id": 11,
            "injected_information_published": "P4L2",
            "level_id": 2,
            "property_id": 4
          },
          {
            "id": 12,
            "injected_information_published": "P4L3",
            "level_id": 3,
            "property_id": 4
          }
        ]
      },
      {
        "id": 5,
        "title": "Property 5",
        "property_order": 5,
        "short_label": "Property 5 short label",
        "injected_selection_about_published": "Property 5 selection about published",
        "injected_long_about_published": "Property 5 long about published",
        "property_levels": [
          {
            "id": 13,
            "injected_information_published": "P5L1",
            "level_id": 1,
            "property_id": 5
          },
          {
            "id": 14,
            "injected_information_published": "P5L2",
            "level_id": 2,
            "property_id": 5
          },
          {
            "id": 15,
            "injected_information_published": "P5L3",
            "level_id": 3,
            "property_id": 5
          }
        ]
      }
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

mockUserDceResponse = {
  "id": 1,
  "dce_question_set_response_id": 1,
  "decision_aid_user_id": 1,
  "question_set": 1
}

describe 'Controller: DecisionAidDceCtrl: ', ->
  beforeEach () ->
    angular.mock.module('dcida20App')
    angular.mock.module('dcida20AppMock')

  DecisionAidDceCtrl = {}
  rootScope = {}
  httpBackend = {}
  Auth = {}
  MockStateService = {}
  MockConfirmService = {}
  _ = {}
  MockUibModalService = {}

  MockDceStandardCtrl = {}
  MockDceConditionalCtrl = {}
  MockDceOptOutCtrl = {}

  controllerParams = {}

  beforeEach inject ($injector, $rootScope, ___, _$q_, _MockNavBroadcastService_, _MockStateService_, _MockConfirmService_,
                     _MockDceStandardCtrl_, _MockDceConditionalCtrl_, _MockDceOptOutCtrl_,
                     _MockUibModalService_) ->
    rootScope = $rootScope
    scope = $rootScope.$new()
    MockStateService = _MockStateService_
    MockConfirmService = _MockConfirmService_
    MockUibModalService = _MockUibModalService_
    _ = ___

    MockDceStandardCtrl = _MockDceStandardCtrl_
    MockDceConditionalCtrl = _MockDceConditionalCtrl_
    MockDceOptOutCtrl = _MockDceOptOutCtrl_

    httpBackend = $injector.get('$httpBackend')

    controllerParams = {
      $scope: scope,
      $stateParams: {decisionAidSlug: "clrcs"},
      $q: _$q_,
      _: _,
      NavBroadcastService: _MockNavBroadcastService_,
      $state: MockStateService,
      Confirm: MockConfirmService,
      DceConditionalCtrl: MockDceConditionalCtrl,
      DceStandardCtrl: MockDceStandardCtrl,
      DceOptOutCtrl: MockDceOptOutCtrl,
      $uibModal: MockUibModalService
    }

  describe "Basic mocks (no current DCE question): ", () ->

    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockDcePageBasic = angular.copy mockDcePageBasic
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/dce').respond(_mockDcePageBasic)

      DecisionAidDceCtrl = $controller 'DecisionAidDceCtrl', controllerParams

      httpBackend.flush()
      
    it "should correctly set the loading variable", () ->
      expect(DecisionAidDceCtrl.loading).toBeFalsy()

    it "submitNext: should go to the first question if switcher is 'readyToSave'", () ->
      DecisionAidDceCtrl.submitNext()
      expect(MockStateService.target).toBe("decisionAidDce")
      expect(MockStateService.params.current_question_set).toBe(1)

  describe "Basic mocks (current DCE question)", () ->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockDcePageBasic = angular.copy mockDcePageBasic
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/dce?current_question_set=1').respond(_mockDcePageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/#{mockDcePageBasic.meta.decision_aid_user.id}/decision_aid_user_dce_question_set_responses/find_by_question_set?question_set=1").respond([])
      httpBackend.whenPOST("http://localhost:3000/api/decision_aid_users/#{mockDcePageBasic.meta.decision_aid_user.id}/decision_aid_user_dce_question_set_responses").respond({})

      controllerParams.$stateParams.current_question_set = 1

      DecisionAidDceCtrl = $controller 'DecisionAidDceCtrl', controllerParams

      httpBackend.flush()
      
    it "should correctly set the loading variable", () ->
      expect(DecisionAidDceCtrl.loading).toBeFalsy()

    it "should set some variables for the view", () ->
      expect(DecisionAidDceCtrl.decisionAid).toBeDefined()
      expect(DecisionAidDceCtrl.properties).toBeDefined()
      expect(DecisionAidDceCtrl.dceQuestionSetResponses).toBeDefined()

    it "should create a new DecisionAidUserDceQuestionSetResponse since the default mock query returns an empty array", () ->
      expect(DecisionAidDceCtrl.userSetResponse).toBeDefined()
      expect(DecisionAidDceCtrl.userSetResponse.id).not.toBeDefined()

    it "should return true from areAllAttributesSetForProperty with the default mock data for all properties", () ->
      expect(DecisionAidDceCtrl.properties.length).toBeGreaterThan(0)
      _.each DecisionAidDceCtrl.properties, (p) =>
        response = DecisionAidDceCtrl.areAllAttributesSetForProperty(p)
        expect(response).toBe(true)

    it "should set correct bools when decisionAidInvalid event is received", () ->
      rootScope.$broadcast 'decisionAidInvalid'

      expect(DecisionAidDceCtrl.loading).toBeFalsy()
      expect(DecisionAidDceCtrl.decisionAid).toBeNull()
      expect(DecisionAidDceCtrl.noDecisionAidFound).toBeTruthy()

    it "should call reset on the dceController when resetResponses is called on the parent", () ->
      expect(DecisionAidDceCtrl.dceController.resetCalled).toBeFalsy()
      DecisionAidDceCtrl.resetResponses()
      expect(DecisionAidDceCtrl.dceController.resetCalled).toBeTruthy()

    # it "setupPropertyLevelColors: should add a different level color when they differ across question sets", () ->
    #   DecisionAidDceCtrl.setupPropertyLevelColors()
    #   expect(DecisionAidDceCtrl.properties.length).toBeGreaterThan(0)
    #   expect(DecisionAidDceCtrl.dceQuestionSetResponses.length).toBeGreaterThan(0)
    #   _.each DecisionAidDceCtrl.properties, (p) =>
    #     pls = []
    #     _.each DecisionAidDceCtrl.dceQuestionSetResponses, (dceQsr) =>
    #       plLevelId = dceQsr.property_level_hash[p.id]
    #       pl = _.find p.property_levels, (pl) =>
    #         pl.level_id is parseInt(plLevelId)
    #       pls.push pl if pl

    #     expect(pls.length).toBeGreaterThan(0)
    #     anyDiff = !_.every(pls, (pl) => pl.level_id is pls[0].level_id)
    #     if anyDiff
    #       _.each pls, (pl) =>
    #         expect(pl.color['background-color']).not.toBe('#ffffff')
    #     else
    #       _.each pls, (pl) =>
    #         expect(pl.color['background-color']).toBe('#ffffff')

    it "should save the response and go to next state", () ->
      DecisionAidDceCtrl.saveUserSetResponse()
      httpBackend.flush()
      expect(MockStateService.target).toBe("decisionAidDce")
      expect(MockStateService.params.current_question_set).toBe(2)

    it "should open a modal popup when the moreInfo function is called", () ->
      expect(MockUibModalService.modalOpened).toBeFalsy()
      DecisionAidDceCtrl.moreInfo(DecisionAidDceCtrl.properties[0])
      expect(MockUibModalService.modalOpened).toBeTruthy()

    it "submitNext: should open a modal if the switcher is 'invalid'", () ->
      DecisionAidDceCtrl.dceController.submit = () => return "invalid"

      expect(MockConfirmService.modalOpened).toBeFalsy()
      DecisionAidDceCtrl.submitNext()
      rootScope.$apply()
      expect(MockConfirmService.modalOpened).toBeTruthy()

    it "submitNext: should not open a modal if switcher is 'firstDecisionCompleted'", () ->
      DecisionAidDceCtrl.dceController.submit = () => return "firstDecisionCompleted"

      expect(MockConfirmService.modalOpened).toBeFalsy()
      DecisionAidDceCtrl.submitNext()
      rootScope.$apply()
      expect(MockConfirmService.modalOpened).toBeFalsy()

    it "submitNext: should go to the next state if switcher is 'readyToSave'", () ->
      DecisionAidDceCtrl.dceController.submit = () => return "readyToSave"

      DecisionAidDceCtrl.submitNext()
      httpBackend.flush()
      expect(MockStateService.target).toBe("decisionAidDce")
      expect(MockStateService.params.current_question_set).toBe(2)

    describe "navigation (forward)", () ->
      it "determineNextState: should go to next DCE question in default case", () ->
        DecisionAidDceCtrl.determineNextState()
        expect(MockStateService.target).toBe("decisionAidDce")
        expect(MockStateService.params.current_question_set).toBe(2)

      it "determineNextState: should go to results page in default case if DCE is finished", () ->
        # pretend this is the last question
        DecisionAidDceCtrl.currentQuestionSet = DecisionAidDceCtrl.decisionAid.dce_question_set_count
        DecisionAidDceCtrl.determineNextState()
        expect(MockStateService.target).toBe("decisionAidResults")

      it "determineNextState: should go to summary page if DCE is finished and decision aid type is 'dce_no_results' and quiz_questions_count = 0", () ->
        # pretend this is the last question
        DecisionAidDceCtrl.currentQuestionSet = DecisionAidDceCtrl.decisionAid.dce_question_set_count
        DecisionAidDceCtrl.decisionAid.decision_aid_type = 'dce_no_results'
        DecisionAidDceCtrl.decisionAid.quiz_questions_count = 0
        DecisionAidDceCtrl.determineNextState()
        expect(MockStateService.target).toBe("decisionAidSummary")

      it "determineNextState: should go to quiz page if DCE is finished and decision aid type is 'dce_no_results' and quiz_questions_count > 0", () ->
        # pretend this is the last question
        DecisionAidDceCtrl.currentQuestionSet = DecisionAidDceCtrl.decisionAid.dce_question_set_count
        DecisionAidDceCtrl.decisionAid.decision_aid_type = 'dce_no_results'
        DecisionAidDceCtrl.determineNextState()
        expect(MockStateService.target).toBe("decisionAidQuiz")

    describe "navigation (backward)", () ->
      it "should go back to previous question in default case", () ->
        DecisionAidDceCtrl.prevLink()
        expect(MockStateService.target).toBe('decisionAidDce')
        expect(MockStateService.params.current_question_set).toBe(0)

      it "should go back to about page if currentQuestionSet is 0", () ->
        DecisionAidDceCtrl.currentQuestionSet = 0
        DecisionAidDceCtrl.prevLink()
        expect(MockStateService.target).toBe('decisionAidAbout')

      it "should go back to intro page if demographic_questions_count is 0 and currentQuestionSet is 0", () ->
        DecisionAidDceCtrl.currentQuestionSet = 0
        DecisionAidDceCtrl.decisionAid.demographic_questions_count = 0
        DecisionAidDceCtrl.prevLink()
        expect(MockStateService.target).toBe('decisionAidIntro')

  describe "Basic mocks (current DCE question), existing response", () ->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockDcePageBasic = angular.copy mockDcePageBasic
      _mockUserDceResponse = angular.copy mockUserDceResponse
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/dce?current_question_set=1').respond(_mockDcePageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/#{mockDcePageBasic.meta.decision_aid_user.id}/decision_aid_user_dce_question_set_responses/find_by_question_set?question_set=1").respond({decision_aid_user_dce_question_set_response: _mockUserDceResponse})
      httpBackend.whenPUT("http://localhost:3000/api/decision_aid_users/#{mockDcePageBasic.meta.decision_aid_user.id}/decision_aid_user_dce_question_set_responses/1").respond({})

      controllerParams.$stateParams.current_question_set = 1

      DecisionAidDceCtrl = $controller 'DecisionAidDceCtrl', controllerParams

      httpBackend.flush()
      
    it "should save the response and go to next state", () ->
      DecisionAidDceCtrl.saveUserSetResponse()
      httpBackend.flush()
      expect(MockStateService.target).toBe("decisionAidDce")
      expect(MockStateService.params.current_question_set).toBe(2)

  describe "With bad request to get decision aid", ( )->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/dce').respond(400)

      DecisionAidDceCtrl = $controller 'DecisionAidDceCtrl', controllerParams

      httpBackend.flush()

    it "Should set correct bools on error", () ->
      expect(DecisionAidDceCtrl.loading).toBeFalsy()
      expect(DecisionAidDceCtrl.decisionAid).toBeNull()
      expect(DecisionAidDceCtrl.noDecisionAidFound).toBeTruthy()

  describe "With bad request to get decisionAidUserDceQuestionSetResponses", ( )->
    beforeEach inject ($controller) ->
      # mock all the backend calls
      _mockDcePageBasic = angular.copy mockDcePageBasic
      httpBackend.whenGET('http://localhost:3000/api/decision_aid_home/dce?current_question_set=1').respond(_mockDcePageBasic)
      httpBackend.whenGET("http://localhost:3000/api/decision_aid_users/#{mockDcePageBasic.meta.decision_aid_user.id}/decision_aid_user_dce_question_set_responses/find_by_question_set?question_set=1").respond(400)

      controllerParams.$stateParams.current_question_set = 1

      DecisionAidDceCtrl = $controller 'DecisionAidDceCtrl', controllerParams

      httpBackend.flush()

    it "Should set correct bools on error", () ->
      expect(DecisionAidDceCtrl.loading).toBeFalsy()
      expect(DecisionAidDceCtrl.decisionAid).toBeNull()
      expect(DecisionAidDceCtrl.noDecisionAidFound).toBeTruthy()