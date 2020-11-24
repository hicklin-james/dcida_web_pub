class DecisionAidPage

  constructor: () ->
    @helpButton = element(By.css('.navbar-collapse .help-me-button'))
    @headerLink = element(By.css('.navbar-brand'))
    @nextButton = element(By.css('.next-nav-button'))
    @prevButton = element(By.css('.prev-nav-button'))
    
  goNext: () ->
    @nextButton.click()

  goBack: () ->
    @prevButton.click()

  openHelp: () ->
    @helpButton.click()

module.exports = DecisionAidPage