class DecisionAidShowPage
  constructor: () ->
    @header = element(By.css('h1'))
    @instructionsHeader = element(By.cssContainingText('h2', "Instructions"))
    @basicHeader = element(By.cssContainingText('h2', "Basic"))
    @stylingHeader = element(By.cssContainingText('h2', "Styling"))
    @introductionHeader = element(By.cssContainingText('h2', "Introduction"))
    @aboutMeHeader = element(By.cssContainingText('h2', "About Me"))
    @myOptionsHeader = element(By.cssContainingText('h2', "My Options"))
    @myPropertiesHeader = element(By.cssContainingText('h2', "My Properties"))
    @myChoiceHeader = element(By.cssContainingText('h2', "My Choice"))
    @quizHeader = element(By.cssContainingText('h2', "Quiz"))
    @summaryHeader = element(By.cssContainingText('h2', "Summary"))

    @basicLink = element(By.partialLinkText("Basic"))
    @stylingLink = element(By.partialLinkText("Styling"))
    @introductionLink = element(By.partialLinkText("Introduction"))
    @aboutMeLink = element(By.partialLinkText("About Me"))
    @myOptionsLink = element(By.partialLinkText("My Options"))
    @myPropertiesLink = element(By.partialLinkText("My Properties"))
    @myChoiceLink = element(By.partialLinkText("My Choice"))
    @quizLink = element(By.partialLinkText("Quiz"))
    @summaryLink = element(By.partialLinkText("Summary"))


module.exports = DecisionAidShowPage