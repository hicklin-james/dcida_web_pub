require('coffee-script/register');

exports.config = {
  specs: [
    'decision_aid_home/standard_decision_aid/intro.coffee',
    'decision_aid_home/standard_decision_aid/about.coffee'
  ],

  // multiCapabilities: [{
  //   'browserName': 'opera'
  // }, {
  // 	'browserName': 'chrome'
  // }, {
  // 	'browserName': 'firefox'
  // }],

  maxSessions: 1,

  onPrepare: function() {
    global.By = global.by;
    // require('protractor-http-mock').config = {
    //   rootDirectory: __dirname,
    //   protractorConfig: 'conf.js'
    // };
  }
};