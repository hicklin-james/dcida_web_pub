# Karma configuration
# http://karma-runner.github.io/0.12/config/configuration-file.html
# Generated on 2015-06-19 using
# generator-karma 1.0.0

module.exports = (config) ->
  config.set
    # base path, that will be used to resolve files and exclude
    basePath: '../'

    # testing framework to use (jasmine/mocha/qunit/...)
    # as well as any additional frameworks (requirejs/chai/sinon/...)
    frameworks: [
      "jasmine"
    ]

    # list of files / patterns to load in the browser
    files: [
      # bower:js
      'bower_components/jquery/dist/jquery.js'
      'bower_components/angular/angular.js'
      'bower_components/angular-animate/angular-animate.js'
      'bower_components/angular-bind-html-compile/angular-bind-html-compile.js'
      'bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
      'bower_components/angular-ui-router/release/angular-ui-router.js'
      'bower_components/angular-breadcrumb/release/angular-breadcrumb.js'
      'bower_components/angular-cookies/angular-cookies.js'
      'bower_components/jquery-ui/ui/jquery-ui.js'
      'bower_components/angular-dragdrop/src/angular-dragdrop.js'
      'bower_components/angular-http-auth/src/http-auth-interceptor.js'
      'bower_components/ui-cropper/compile/minified/ui-cropper.js'
      'bower_components/intro.js/intro.js'
      'bower_components/angular-intro.js/src/angular-intro.js'
      'bower_components/moment/moment.js'
      'bower_components/angular-moment/angular-moment.js'
      'bower_components/angular-redactor/angular-redactor.js'
      'bower_components/angular-resource/angular-resource.js'
      'bower_components/angular-sanitize/angular-sanitize.js'
      'bower_components/angular-translate/angular-translate.js'
      'bower_components/angular-scroll/angular-scroll.js'
      'bower_components/angular-touch/angular-touch.js'
      'bower_components/angular-ui-slider/src/slider.js'
      'bower_components/bootstrap-sass-official/assets/javascripts/bootstrap.js'
      'bower_components/jqueryui-touch-punch/jquery.ui.touch-punch.min.js'
      'bower_components/highcharts/highcharts.js'
      'bower_components/highcharts/highcharts-more.js'
      'bower_components/highcharts/modules/exporting.js'
      'bower_components/highcharts-ng/dist/highcharts-ng.js'
      'bower_components/ng-file-upload/ng-file-upload.js'
      'bower_components/ng-slide-down/dist/ng-slide-down.js'
      'bower_components/redactor/redactor.js'
      'bower_components/redactor/redactor-plugins/imagemanager.js'
      'bower_components/redactor/redactor-plugins/video.js'
      'bower_components/underscore/underscore.js'
      'bower_components/my-angular-sortable-view/angular-sortable-view.js'
      'bower_components/d3/d3.min.js'
      'bower_components/angular-bootstrap-colorpicker/js/bootstrap-colorpicker-module.js'
      'bower_components/websocket-rails/websocket-rails.js'
      'bower_components/angular-ui-select/dist/select.js'
      'bower_components/angular-vs-repeat/src/angular-vs-repeat.js'
      'bower_components/ng-sortable/dist/ng-sortable.js'
      'bower_components/ngSilent/ngSilent.js'
      'bower_components/rainbowvis/rainbowvis.js'
      'bower_components/bootstro/bootstro.js'
      'bower_components/angularSlideables/angularSlideables.js'
      'bower_components/angular-ui-carousel/dist/ui-carousel.js'
      'bower_components/angular-mocks/angular-mocks.js'
      # endbower
      # bower:coffee
      # endbower
      "test/mock/**/*.coffee"
      "app/scripts/**/*.coffee"
      "test/spec/**/*.coffee"
      "app/scripts/theme_config.js"
      
      "app/scripts/underscore.string.js"
      "app/scripts/theme_config.js"
    ],

    # list of files / patterns to exclude
    exclude: [
    ]

    # web server port
    port: 8080

    # level of logging
    # possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari (only Mac)
    # - PhantomJS
    # - IE (only Windows)
    browsers: [
      "PhantomJS"
    ]

    # Which plugins to enable
    plugins: [
      "karma-phantomjs-launcher",
      "karma-jasmine",
      "karma-coffee-preprocessor",
      "karma-coverage"
    ]

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false

    colors: true

    preprocessors: {
      '**/*.coffee': ['coffee', 'coverage']
    }

    reporters: ['progress', 'coverage']

    coverageReporter: {
      includeAllSources: true,
      dir: 'test/coverage/',
      reporters: [
        { type: "html", subdir: "html" },
        { type: 'text-summary' }
      ]
    }

    # Uncomment the following lines if you are using grunt's server to run the tests
    # proxies: '/': 'http://localhost:9000/'
    # URL root prevent conflicts with the site root
    # urlRoot: '_karma_'
