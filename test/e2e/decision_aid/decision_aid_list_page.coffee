class DecisionAidListPage

  constructor: () ->
    @header = element(By.css('h1'))
    @goToNewDecisionAidButton = element(By.id('new-decision-aid-btn'))
    @searchBox = element(By.id("decision-aid-search"))

  enterSearchText: (text) ->
    @searchBox.clear()
    @searchBox.sendKeys(text)

  getDecisionAidItems: () ->
    element.all(By.css('.decision-aid-items'))


module.exports = DecisionAidListPage