# DCIDA Web Application

Dynamic Computer Interactive Decision Application (DCIDA) is a dynamic CMS-like decision
aid tool that can be used to make customizable decision aids. This is the web app for DCIDA.

## Dependencies (for development, on Mac OS X)
* NPM 2.12.1
* Compass 1.0.3 (`gem install compass`)
* yo
* grunt
* angular

## Web App Setup
1. `npm install`
2. `bower update`

## Running the web app
`grunt serve`

## Running the tests
`grunt test`

## Building for production
`grunt buildProduction`

## Deploying to production
`ruby deploy.rb`

Running `grunt test` will run the unit tests with karma.
