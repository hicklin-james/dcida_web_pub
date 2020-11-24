DecisionAidPage = require('./decision_aid_page')

class DecisionAidIntroPage extends DecisionAidPage

  constructor: () ->
    super()
    @pageContent = element(By.css('#intro-page-wrapper'))
    @error = element(By.css('.alert'))

  getModal: () ->
    element(By.css('.modal-header'))

  closeModal: () ->
    element(By.css('.modal-footer .btn')).click()


module.exports = DecisionAidIntroPage