Seed = require('../../seed')
DecisionAidIntroPage = require('../decision_aid_intro_page')

describe 'decisionAidHome/intro', () ->

  beforeEach () ->
    seed = new Seed()
    seed.prepare({"decision_aid_to_load": "standard_decision_aid"})

  it 'should go to the intro page when we access via http://localhost:8999/#/decision_aid/standard', () ->
    browser.get("http://localhost:8999/#/decision_aid/standard")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)
    expect(decisionAidIntroPage.error.isDisplayed()).not.toBe(true)

  it 'should go to the intro page when we access via http://localhost:8999/#/decision_aid/standard/', () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

  it 'should go to the intro page when we access via http://localhost:8999/#/decision_aid/standard/intro', () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

  it 'should go to the next intro page when the next button is clicked', () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)
    introPageText = decisionAidIntroPage.pageContent.getText()

    decisionAidIntroPage.goNext()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=2')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)
    otherIntroPageText = decisionAidIntroPage.pageContent.getText()
    expect(introPageText).not.toEqual(otherIntroPageText)

  it 'should leave the intro pages when all 3 intro pages are clicked through', () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')

    decisionAidIntroPage.goNext()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=2')

    decisionAidIntroPage.goNext()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=3')

    decisionAidIntroPage.goNext()

    browser.waitForAngular()

    # should no longer be an intro page
    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(false)

  it "should navigate forwards and backwards properly", () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)
    decisionAidIntroPage.goNext()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=2')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

    decisionAidIntroPage.goBack()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

    decisionAidIntroPage.goNext()
    browser.waitForAngular()
    decisionAidIntroPage.goNext()
    browser.waitForAngular()
    decisionAidIntroPage.goNext()
    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(false)

    decisionAidIntroPage.goBack()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=3')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

  it "should navigate using curr_intro_page_order properly", () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")
    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

    browser.get("http://localhost:8999/#/decision_aid/standard/intro?curr_intro_page_order=3")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=3')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

    decisionAidIntroPage.goBack()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=2')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)


  it "should not allow navigation to other sections that are not yet available", () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

    browser.get("http://localhost:8999/#/decision_aid/standard/properties")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('/intro')
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

  it "should show an error message if the slug doesn't match a real decision aid", () ->
    browser.get("http://localhost:8999/#/decision_aid/fake_decision_aid/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).not.toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(false)
    expect(decisionAidIntroPage.error.isDisplayed()).toBe(true)

  it "should go back to the first intro page when the decision aid title in the header bar is clicked", () ->
    browser.get("http://localhost:8999/#/decision_aid/standard/intro")

    decisionAidIntroPage = new DecisionAidIntroPage()
    decisionAidIntroPage.goNext()
    browser.waitForAngular()
    decisionAidIntroPage.goNext()
    browser.waitForAngular()
    decisionAidIntroPage.goNext()
    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(false) 

    decisionAidIntroPage.headerLink.click()

    browser.waitForAngular()

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.pageContent.isPresent()).toBe(true)

describe 'decisionAidHome/introWithPopup', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "decision_aid": {
          "has_intro_popup": true,
          "intro_popup_information": "Test information"
        }
      }
    }
    seed.prepare(params)

  it "should show an intro popup when DCIDA loads", () ->
    browser.get("http://localhost:8999/#/decision_aid/standard")
    browser.sleep(500)

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.getModal().isDisplayed()).toBe(true)

    decisionAidIntroPage.closeModal()
    browser.waitForAngular()
    browser.sleep(500)

    expect(decisionAidIntroPage.getModal().isPresent()).toBe(false)

describe 'decisionAidHome/introWithHelpMeButton', () ->

  beforeEach () ->
    seed = new Seed()
    params = {
      "decision_aid_to_load": "standard_decision_aid",
      "additional_params": {
        "decision_aid": {
          "description": "Test help me info"
        }
      }
    }
    seed.prepare(params)

  it "should show a help me button that opens a modal", () ->
    browser.get("http://localhost:8999/#/decision_aid/standard")

    decisionAidIntroPage = new DecisionAidIntroPage()
    expect(browser.getCurrentUrl()).toContain('curr_intro_page_order=1')
    expect(decisionAidIntroPage.getModal().isPresent()).toBe(false)
    expect(decisionAidIntroPage.helpButton.isPresent()).toBe(true)
    expect(decisionAidIntroPage.helpButton.isDisplayed()).toBe(true)

    decisionAidIntroPage.openHelp()
    browser.waitForAngular()
    browser.sleep(500)

    expect(decisionAidIntroPage.getModal().isPresent()).toBe(true)
    expect(decisionAidIntroPage.getModal().isDisplayed()).toBe(true)

