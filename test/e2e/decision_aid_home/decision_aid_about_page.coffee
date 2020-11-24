DecisionAidPage = require('./decision_aid_page')

class DecisionAidAboutPage extends DecisionAidPage

  constructor: () ->
    super()
    @pageContent = element(By.css('#about_content'))

    @textQuestion = element(By.css('.text-question-type'))
    @radioQuestion = element(By.css('.radio-question-type'))
    @sliderQuestion = element(By.css('.slider-question-type'))
    @numberQuestion = element(By.css('.number-question-type'))
    @rankingQuestion = element(By.css('.ranking-question-type'))

  getModal: () ->
    element(By.css('.modal-body'))

  closeInfoModal: () ->
    @getModal().element(By.css('[ng-click="ctrl.dismiss()"]')).click()

  confirmShowModal: () ->
    @getModal().element(By.css('[ng-click="ctrl.confirm()"]')).click()

  cancelShowModal: () ->
    @getModal().element(By.css('[ng-click="ctrl.cancel()"]')).click()

  answerTextQuestion: (text) ->
    @getTextArea().sendKeys(text)

  getTextArea: () ->
    @textQuestion.element(By.css("textarea"))

  getTextValue: () ->
    @getTextArea().getAttribute("value")

  answerRadioQuestion: () ->
    inputs = @radioQuestion.all(By.css('[ng-click="ctrl.selectResponse(ctrl.qc.currentQuestion, response)"]'))
    inputs.count().then((numItems) =>
      return Math.floor(Math.random() * numItems)
    ).then((randomNum) =>
      inputs.get(randomNum).click()
      return randomNum
    )

  getInputAtIndex: (index) ->
    inputs = @radioQuestion.all(By.css('[ng-click="ctrl.selectResponse(ctrl.qc.currentQuestion, response)"]'))
    inputs.get(index)

  getSliderElement: () ->
    @sliderQuestion.element(By.css('.ui-slider'))

  getSliderHandle: () ->
    @getSliderElement().element(By.css('.ui-slider-handle'))

  answerSliderQuestion: (xToMove, yToMove) ->
    browser.driver.actions().dragAndDrop(@getSliderHandle(), {x: xToMove, y: yToMove}).mouseUp().perform()

  getNumberInput: () ->
    @numberQuestion.element(By.css('.number-input input'))

  getNumberValue: () ->
    @getNumberInput().getAttribute("value")

  answerNumberQuestion: (num) ->
    @getNumberInput().sendKeys(num)

  getRankingOptions: () ->
    @rankingQuestion.all(By.css('.selectable-options .rank-option-wrapper'))

  getRankedOptions: () ->
    @rankingQuestion.all(By.css('.selected-options .rank-option-wrapper'))

  shuffleArray: (array) ->
    for i in [0...array.length]
      j = Math.floor(Math.random() * (i + 1))
      temp = array[i]
      array[i] = array[j]
      array[j] = temp

  reorderRankedItems: (startIndex, endIndex) =>
    options = @getRankedOptions()
    offset = (if startIndex > endIndex then -1 else 1)
    startDrag = options.get(startIndex).element(By.css('.drag-icon'))
    endDrag = options.get(endIndex).element(By.css('.drag-icon'))
    startDrag.getLocation().then (posStart) =>
      endDrag.getLocation().then (posEnd) =>
        browser.driver.actions().dragAndDrop(startDrag, {x: posEnd.x - posStart.x, y: posEnd.y - posStart.y + offset}).mouseUp().perform()

  answerRankingQuestion: () ->
    rankingOptions = @getRankingOptions()
    rankingOptions.count().then((numItems) =>
      indices = new Array(numItems)
      for i in [0...numItems]
        indices[i] = i
      @shuffleArray(indices)

      promises = []
      for index in indices
        promises.push rankingOptions.get(index).click()

      return protractor.promise.all(promises)
    )


module.exports = DecisionAidAboutPage