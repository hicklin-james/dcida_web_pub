Seed = require('../../seed')
DecisionAidIntroPage = require('../decision_aid_intro_page')
DecisionAidAboutPage = require('../decision_aid_about_page')

goToAbout = () ->
  browser.get("http://localhost:8999/#/decision_aid/standard")

  decisionAidIntroPage = new DecisionAidIntroPage()
  decisionAidIntroPage.goNext()
  browser.waitForAngular()
  decisionAidIntroPage.goNext()
  browser.waitForAngular()
  decisionAidIntroPage.goNext()
  browser.waitForAngular()

#------------------------------------------------#
#---------------- Text questions ----------------#
#------------------------------------------------#
describe 'decisionAidHome/aboutWithTextQuestion', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "text"
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should show a text question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.textQuestion.isPresent()).toBe(true)

  it 'should navigate to the next section after answering the question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.textQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerTextQuestion("Test text")

    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(false)

  it 'should reload the response into the question when I go back to this page', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.textQuestion.isPresent()).toBe(true)
    responseValue = "Test text"
    decisionAidAboutPage.answerTextQuestion(responseValue)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getTextValue()).toEqual(responseValue)

  it 'should not save anything if I go back after entering something', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.textQuestion.isPresent()).toBe(true)
    responseValue = "Test text"
    decisionAidAboutPage.answerTextQuestion(responseValue)
    expect(decisionAidAboutPage.getTextValue()).toEqual(responseValue)

    decisionAidAboutPage.goBack()
    browser.waitForAngular()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getTextValue()).not.toEqual(responseValue)
    expect(decisionAidAboutPage.getTextValue()).toBe('')

  it 'should prevent navigation to next question if question isnt answered', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.closeInfoModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)


describe 'decisionAidHome/aboutWithTextQuestionThatCantBeChanged', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "text",
            "can_change_response": false
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should not allow changes to response after saving', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.textQuestion.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getTextArea().isEnabled()).toBe(true)
    responseValue = "Test text"
    decisionAidAboutPage.answerTextQuestion(responseValue)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getTextValue()).toEqual(responseValue)
    expect(decisionAidAboutPage.getTextArea().isEnabled()).toBe(false)

describe 'decisionAidHome/aboutWithTextQuestionThatCanBeSkipped', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "text",
            "skippable": true
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should allow empty response to be skipped after showing modal notice and confirming', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.confirmShowModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).not.toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

  it 'should not go to the next question if the question is skippable and the modal is cancelled', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.cancelShowModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

#------------------------------------------------#
#--------------- Radio questions ----------------#
#------------------------------------------------#
describe 'decisionAidHome/aboutWithRadioQuestion', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "radio"
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should show a radio question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.radioQuestion.isPresent()).toBe(true)

  it 'should navigate to the next section after answering the question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.radioQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerRadioQuestion()

    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(false)

  it 'should reload the response into the question when I go back to this page', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.radioQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerRadioQuestion().then (selectedResponseIndex) =>
      decisionAidAboutPage.goNext()
      browser.waitForAngular()
      decisionAidAboutPage.goBack()
      browser.waitForAngular()

      decisionAidAboutPage = new DecisionAidAboutPage()
      expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
      expect(decisionAidAboutPage.getInputAtIndex(selectedResponseIndex).getAttribute('class')).toContain("btn-success")

  it 'should not save anything if I go back after entering something', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.radioQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerRadioQuestion().then (selectedResponseIndex) =>

      decisionAidAboutPage.goBack()
      browser.waitForAngular()
      decisionAidAboutPage.goNext()
      browser.waitForAngular()

      decisionAidAboutPage = new DecisionAidAboutPage()
      expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
      expect(decisionAidAboutPage.radioQuestion.isPresent()).toBe(true)
      expect(decisionAidAboutPage.getInputAtIndex(selectedResponseIndex).getAttribute('class')).not.toContain("btn-success")

  it 'should prevent navigation to next question if question isnt answered', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.closeInfoModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

describe 'decisionAidHome/aboutWithRadioQuestionThatCantBeChanged', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "radio",
            "can_change_response": false
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should not allow changes to response after saving', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.radioQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.getInputAtIndex(1).click()
    
    browser.waitForAngular()

    expect(decisionAidAboutPage.getInputAtIndex(1).getAttribute('class')).toContain("btn-success")

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    newResponseIndex = 0

    decisionAidAboutPage.getInputAtIndex(newResponseIndex).click()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getInputAtIndex(newResponseIndex).getAttribute('class')).not.toContain("btn-success")
    expect(decisionAidAboutPage.getInputAtIndex(1).getAttribute('class')).toContain("btn-success")
    
describe 'decisionAidHome/aboutWithRadioQuestionThatCanBeSkipped', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "radio",
            "skippable": true
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should allow empty response to be skipped after showing modal notice and confirming', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.confirmShowModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).not.toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

  it 'should not go to the next question if the question is skippable and the modal is cancelled', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.cancelShowModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

#------------------------------------------------#
#--------------- Slider questions ---------------#
#------------------------------------------------#
describe 'decisionAidHome/aboutWithSliderQuestion', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "slider"
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should show a slider question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)

  it 'should be an interactable slider', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)

    sliderHandle = decisionAidAboutPage.getSliderHandle()
    sliderHandle.getLocation().then (locationa) =>
      decisionAidAboutPage.answerSliderQuestion(100, 0)
      sliderHandle.getLocation().then (locationb) =>
        expect(locationa.x).not.toBe(locationb.x)
        expect(locationa.y).toBe(locationb.y)

  it 'should navigate to the next section after answering the question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerSliderQuestion(100, 0)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(false)

  it 'should reload the response into the question when I go back to this page', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)

    sliderHandle = decisionAidAboutPage.getSliderHandle()
    sliderHandle.getLocation().then (locationa) =>

      decisionAidAboutPage.answerSliderQuestion(100, 0)
      sliderHandle = decisionAidAboutPage.getSliderHandle()
      sliderHandle.getLocation().then (locationb) =>

        expect(locationa.x).not.toBe(locationb.x)
        expect(locationa.y).toBe(locationb.y)

        decisionAidAboutPage.goNext()
        browser.waitForAngular()
        decisionAidAboutPage.goBack()
        browser.waitForAngular()

        decisionAidAboutPage = new DecisionAidAboutPage()
        expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
        expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)
        sliderHandle = decisionAidAboutPage.getSliderHandle()
        sliderHandle.getLocation().then (locationc) =>
          expect(locationb.x).toBe(locationc.x)
          expect(locationb.y).toBe(locationc.y)

  it 'should not save anything if I go back after entering something', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)

    decisionAidAboutPage.answerSliderQuestion(100, 0)

    sliderHandle = decisionAidAboutPage.getSliderHandle()
    sliderHandle.getLocation().then (locationa) =>
      decisionAidAboutPage.goBack()
      browser.waitForAngular()
      decisionAidAboutPage.goNext()
      browser.waitForAngular()

      decisionAidAboutPage = new DecisionAidAboutPage()
      expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
      expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)
      sliderHandle = decisionAidAboutPage.getSliderHandle()
      sliderHandle.getLocation().then (locationb) =>
        expect(locationa.x).not.toBe(locationb.x)
        expect(locationa.y).toBe(locationb.y)

describe 'decisionAidHome/aboutWithSliderQuestionThatCantBeChanged', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "slider",
            "can_change_response": false
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should not allow changes to response after saving', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerSliderQuestion(100, 0)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)
    sliderHandle = decisionAidAboutPage.getSliderHandle()
    sliderHandle.getLocation().then (locationa) =>

      decisionAidAboutPage.answerSliderQuestion(-200, 0)

      sliderHandle = decisionAidAboutPage.getSliderHandle()
      sliderHandle.getLocation().then (locationb) =>
        expect(locationa.x).toBe(locationb.x)
        expect(locationa.y).toBe(locationb.y)

describe 'decisionAidHome/aboutWithVerticalSliderQuestion', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "slider",
            "question_response_style": "vertical_slider"
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should also work with vertical sliders', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)

    sliderHandle = decisionAidAboutPage.getSliderHandle()
    sliderHandle.getLocation().then (locationa) =>

      decisionAidAboutPage.answerSliderQuestion(0, 100)
      sliderHandle = decisionAidAboutPage.getSliderHandle()
      sliderHandle.getLocation().then (locationb) =>

        expect(locationa.x).toBe(locationb.x)
        expect(locationa.y).not.toBe(locationb.y)

        decisionAidAboutPage.goNext()
        browser.waitForAngular()
        decisionAidAboutPage.goBack()
        browser.waitForAngular()

        decisionAidAboutPage = new DecisionAidAboutPage()
        expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
        expect(decisionAidAboutPage.sliderQuestion.isPresent()).toBe(true)
        sliderHandle = decisionAidAboutPage.getSliderHandle()
        sliderHandle.getLocation().then (locationc) =>
          expect(locationb.x).toBe(locationc.x)
          expect(locationb.y).toBe(locationc.y)

#------------------------------------------------#
#--------------- Number questions ---------------#
#------------------------------------------------#
describe 'decisionAidHome/aboutWithNumberQuestion', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "number"
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should show a number question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.numberQuestion.isPresent()).toBe(true)

  it 'should navigate to the next section after answering the question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.numberQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerNumberQuestion(10)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(false)

  it 'should reload the response into the question when I go back to this page', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.numberQuestion.isPresent()).toBe(true)
    responseValue = 10
    decisionAidAboutPage.answerNumberQuestion(responseValue)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getNumberValue()).toEqual(responseValue.toString())

  it 'should not save anything if I go back after entering something', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.numberQuestion.isPresent()).toBe(true)
    responseValue = 10
    decisionAidAboutPage.answerNumberQuestion(responseValue)
    expect(decisionAidAboutPage.getNumberValue()).toEqual(responseValue.toString())

    decisionAidAboutPage.goBack()
    browser.waitForAngular()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getNumberValue()).not.toEqual(responseValue.toString())
    expect(decisionAidAboutPage.getNumberValue()).toBe('')

  it 'should prevent navigation to next question if question isnt answered', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.closeInfoModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

describe 'decisionAidHome/aboutWithNumberQuestionThatCantBeChanged', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "number",
            "can_change_response": false
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should not allow changes to response after saving', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.numberQuestion.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getNumberInput().isEnabled()).toBe(true)
    responseValue = 10
    decisionAidAboutPage.answerNumberQuestion(responseValue)

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getNumberValue()).toEqual(responseValue.toString())
    expect(decisionAidAboutPage.getNumberInput().isEnabled()).toBe(false)

describe 'decisionAidHome/aboutWithNumberQuestionThatCanBeSkipped', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "number",
            "skippable": true
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should allow empty response to be skipped after showing modal notice and confirming', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.confirmShowModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).not.toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

  it 'should not go to the next question if the question is skippable and the modal is cancelled', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.cancelShowModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

#------------------------------------------------#
#-------------- Ranking questions ---------------#
#------------------------------------------------#
describe 'decisionAidHome/aboutWithRankingQuestion', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "ranking"
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should show a ranking question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)

  it "should add elements to the right pane when elements on the left pane are clicked", () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getRankingOptions().count()).not.toBe(decisionAidAboutPage.getRankedOptions().count())
    decisionAidAboutPage.answerRankingQuestion().then () =>
      expect(decisionAidAboutPage.getRankingOptions().count()).toBe(decisionAidAboutPage.getRankedOptions().count())

  it "should not add the same element twice to the right pane", () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getRankedOptions().count()).toBe(0)
    decisionAidAboutPage.getRankingOptions().get(0).click()
    expect(decisionAidAboutPage.getRankedOptions().count()).toBe(1)
    decisionAidAboutPage.getRankingOptions().get(0).click()
    expect(decisionAidAboutPage.getRankedOptions().count()).toBe(1)
    decisionAidAboutPage.getRankingOptions().get(1).click()
    expect(decisionAidAboutPage.getRankedOptions().count()).toBe(2)

  it "should reorder things properly", () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.getRankingOptions().get(0).click()
    decisionAidAboutPage.getRankingOptions().get(1).click()

    decisionAidAboutPage.getRankedOptions().then (items) =>
      decisionAidAboutPage.reorderRankedItems(0, 1)
      decisionAidAboutPage.getRankedOptions().then (newItems) =>
        expect(newItems[0].getText()).not.toBe(items[0].getText())

  it 'should navigate to the next section after answering the question', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)
    
    decisionAidAboutPage.answerRankingQuestion()

    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(false)

  it 'should reload the response into the question when I go back to this page', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerRankingQuestion()

    texts = decisionAidAboutPage.getRankedOptions().getText()

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    reloadedTexts = decisionAidAboutPage.getRankedOptions().getText()

    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(reloadedTexts).toEqual(texts)

  it 'should not save anything if I go back after entering something', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)
    decisionAidAboutPage.answerRankingQuestion()

    expect(decisionAidAboutPage.getRankedOptions().count()).toBeGreaterThan(0)

    decisionAidAboutPage.goBack()
    browser.waitForAngular()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.getRankedOptions().count()).toBe(0)

    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)

  it 'should prevent navigation to next question if question isnt answered', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.closeInfoModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

  it 'should prevent navigation to next question if question isnt fully answered', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()

    decisionAidAboutPage.getRankingOptions().get(0).click()
    expect(decisionAidAboutPage.getRankedOptions().count()).toBe(1)

    lastUrl = browser.getCurrentUrl()
    decisionAidAboutPage.goNext()

    browser.waitForAngular()

    expect(decisionAidAboutPage.getModal().isPresent()).toBe(true)
    expect(decisionAidAboutPage.getModal().isDisplayed()).toBe(true)

    decisionAidAboutPage.closeInfoModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(browser.getCurrentUrl()).toEqual(lastUrl)
    expect(decisionAidAboutPage.getModal().isPresent()).toBe(false)

describe 'decisionAidHome/aboutWithRankingQuestionThatCantBeChanged', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "questions": [
          {
            "type": "ranking",
            "can_change_response": false
          }
        ]
      }
    }
    seed.prepare(params)
    goToAbout()

  it 'should not allow changes to response after saving', () ->
    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    decisionAidAboutPage.goNext()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)

    decisionAidAboutPage.answerRankingQuestion()

    decisionAidAboutPage.goNext()
    browser.waitForAngular()
    decisionAidAboutPage.goBack()
    browser.waitForAngular()

    decisionAidAboutPage = new DecisionAidAboutPage()
    expect(decisionAidAboutPage.rankingQuestion.isPresent()).toBe(true)

    decisionAidAboutPage.getRankedOptions().then (items) =>
      decisionAidAboutPage.reorderRankedItems(0, 1)
      decisionAidAboutPage.getRankedOptions().then (newItems) =>
        expect(newItems[0].getText()).toBe(items[0].getText())