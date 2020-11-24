class SigninPage
  constructor: () ->
    @username = element(By.model('ctrl.credentials.email'))
    @password = element(By.model('ctrl.credentials.password'))
    @loginButton = element(By.buttonText('Sign in'))
    @error = element(By.id('sign-in-error'))

  visit: () ->
    browser.get('http://localhost:8999')
 
  setUsername: (username) ->
    @username.clear()
    @username.sendKeys(username)
 
  setPassword: (password) ->
    @password.clear()
    @password.sendKeys(password)
 
  login: () ->
    @loginButton.click()

  loginToDcida: () ->
    @visit()
    @setUsername('admin@tt.com')
    @setPassword('test123')
    @login()

module.exports = SigninPage