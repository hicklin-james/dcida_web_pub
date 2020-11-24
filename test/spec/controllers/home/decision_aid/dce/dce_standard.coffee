'use strict'

mockDceStandardBasic = {
  "decision_aid": {
    "id": 4,
    "title": "Colorectal Cancer Screening",
    "slug": "clrcs",
    "dce_type": "normal",
    "dce_question_set_title": "Question Set 1",
    "include_dce_confirmation_question": true,
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

mockUserDceStandardResponse = {
  "decision_aid_user_id": 1,
  "question_set": 1
}

describe 'Factory: DceStandardCtrl: ', ->
  beforeEach () ->
    angular.mock.module('dcida20App')
    angular.mock.module('dcida20AppMock')

  DceStandardCtrl = {}
  rootScope = {}

  constructorParams = {}

  beforeEach inject ($injector, $rootScope, ___, _$q_) ->
    rootScope = $rootScope
    scope = $rootScope.$new()


    constructorParams = {
      scope: scope,
      decisionAid: angular.copy(mockDceStandardBasic.decision_aid),
      decisionAidUser: angular.copy(mockDceStandardBasic.meta.decision_aid_user),
      properties: angular.copy(mockDceStandardBasic.properties),
      dceQuestionSetResponses: angular.copy(mockDceStandardBasic.decision_aid.dce_question_set_responses),
      userSetResponse: angular.copy(mockUserDceStandardResponse)
    }

  describe "Basic mocks: ", () ->

    beforeEach inject (_DceStandardCtrl_) ->

      DceStandardCtrl = new _DceStandardCtrl_(
        constructorParams.scope,
        constructorParams.decisionAid,
        constructorParams.decisionAidUser,
        constructorParams.properties,
        constructorParams.dceQuestionSetResponses,
        constructorParams.userSetResponse
      )
      
    it "should correctly fill the tasks array", () ->
      expect(DceStandardCtrl.tasks.length).toBeGreaterThan(0)

    it "selectQsr: should set the dce_question_set_response_id of the userSetResponse and set the first task to finished", () ->
      expect(DceStandardCtrl.tasks[0]).toBeFalsy()
      DceStandardCtrl.selectQsr(DceStandardCtrl.dceQuestionSetResponses[0])
      expect(DceStandardCtrl.userSetResponse.dce_question_set_response_id).toBe(DceStandardCtrl.dceQuestionSetResponses[0].id)
      expect(DceStandardCtrl.tasks[0]).toBeTruthy()

    it "setOptionConfirmed: should set the option_confirmed value of the userSetResponse to the input value if the first task is complete", () ->
      DceStandardCtrl.tasks[0] = true
      expect(DceStandardCtrl.setOptionConfirmed(true)).toBeTruthy()
      expect(DceStandardCtrl.userSetResponse.option_confirmed).toBeTruthy()
      expect(DceStandardCtrl.setOptionConfirmed(false)).toBeTruthy()
      expect(DceStandardCtrl.userSetResponse.option_confirmed).toBeFalsy()

    it "setOptionConfirmed: returns false if userSetResponse.dce_question_set_response_id not yet set", () ->
      expect(DceStandardCtrl.setOptionConfirmed(true)).toBeFalsy()

    it "readyForSubmit: returns 'invalid' if called before option_confirmed when include_dce_confirmation_question is set", () ->
      DceStandardCtrl.selectQsr(DceStandardCtrl.dceQuestionSetResponses[0])
      expect(DceStandardCtrl.readyForSubmit()).toBe('invalid')

    it "readyForSubmit: returns 'readyToSave' if option_confirmed and dce_question_set_response_id are both properly set on the user response", () ->
      DceStandardCtrl.selectQsr(DceStandardCtrl.dceQuestionSetResponses[0])
      DceStandardCtrl.setOptionConfirmed(true)
      expect(DceStandardCtrl.readyForSubmit()).toBe('readyToSave')

    it "shouldAutoSubmit: should return false since include_dce_confirmation_question is true", () ->
      expect(DceStandardCtrl.shouldAutoSubmit()).toBeFalsy()

    it "reset: should nullify important values", () ->
      DceStandardCtrl.userSetResponse.dce_question_set_response_id = 123
      DceStandardCtrl.userSetResponse.fallback_question_set_id = 123
      DceStandardCtrl.userSetResponse.option_confirmed = true
      DceStandardCtrl.tasks[0] = true
      DceStandardCtrl.tasks[1] = true
      DceStandardCtrl.reset()
      expect(DceStandardCtrl.userSetResponse.dce_question_set_response_id).toBeNull()
      expect(DceStandardCtrl.userSetResponse.fallback_question_set_id).toBeNull()
      expect(DceStandardCtrl.userSetResponse.option_confirmed).toBeNull()
      expect(DceStandardCtrl.tasks[0]).toBeFalsy()
      expect(DceStandardCtrl.tasks[1]).toBeFalsy()

  describe "Basic mocks (include_dce_confirmation_question = false on decision aid) ", () ->
    beforeEach inject (_DceStandardCtrl_) ->
      constructorParams.decisionAid.include_dce_confirmation_question = false

      DceStandardCtrl = new _DceStandardCtrl_(
          constructorParams.scope,
          constructorParams.decisionAid,
          constructorParams.decisionAidUser,
          constructorParams.properties,
          constructorParams.dceQuestionSetResponses,
          constructorParams.userSetResponse
        )

    it "readyForSubmit: returns 'readyToSave if dce_question_set_response_id is set on the user response", () ->
      DceStandardCtrl.selectQsr(DceStandardCtrl.dceQuestionSetResponses[0])
      expect(DceStandardCtrl.readyForSubmit()).toBe('readyToSave')

    it "still returns 'readyToSave' if somehow tasks[0] gets set to false (SHOULD NOT BE POSSIBLE)", () ->
      DceStandardCtrl.selectQsr(DceStandardCtrl.dceQuestionSetResponses[0])
      DceStandardCtrl.tasks[0] = false
      expect(DceStandardCtrl.readyForSubmit()).toBe('readyToSave')

    it "shouldAutoSubmit: should return true since include_dce_confirmation_question is false", () ->
      expect(DceStandardCtrl.shouldAutoSubmit()).toBeTruthy()
