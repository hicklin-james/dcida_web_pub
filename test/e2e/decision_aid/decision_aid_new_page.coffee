class DecisionAidNewPage
  constructor: () ->
    @header = element(By.css('h2'))
    @title = element(By.model('ctrl.decisionAid.title'))
    @slug = element(By.model('ctrl.decisionAid.slug'))
    @decisionAidTypeSelector = element(By.id('decision-aid-type-selector'))
    @saveButton = element(By.id('save-button'))

  getStandardDecisionAidJson: () ->
    da = 
      id: 5
      title: "Standard from protractor"
      slug: "sfp"
      description: "blah"
      updated_at: null
      creator: "Joe Connington"
      decision_aid_type: "standard"
    da

  setTitle: (title) ->
    @title.clear()
    @title.sendKeys(title)

  setSlug: (slug) ->
    @slug.clear()
    @slug.sendKeys(slug)

  setDecisionAidType: (type) ->
    @decisionAidTypeSelector.element(By.linkText(type)).click()

  createStandardDecisionAid: () ->
    @setTitle('Standard from protractor')
    @setSlug("sfp")
    @setDecisionAidType("Standard")
    @saveButton.click()

module.exports = DecisionAidNewPage