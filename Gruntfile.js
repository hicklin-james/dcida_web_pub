// Generated on 2015-06-19 using generator-angular 0.11.1
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  grunt.loadNpmTasks('grunt-ngdocs');
  grunt.loadNpmTasks('grunt-protractor-runner');
  grunt.loadNpmTasks('grunt-angular-templates');
  grunt.loadNpmTasks( "grunt-shared-config" );
  grunt.loadNpmTasks('grunt-run');
  grunt.loadNpmTasks('grunt-bless');
  //grunt.loadNpmTasks('grunt-mocha-test');
  //grunt.loadNpmTasks('grunt-istanbul');

  // Configurable paths for the application
  var appConfig = {
    app: require('./bower.json').appPath || 'app',
    dist: 'dist'
  };

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Project settings
    yeoman: appConfig,

    // Watches files for changes and runs tasks based on the changed files
    watch: {
      bower: {
        files: ['bower.json'],
        tasks: ['wiredep']
      },
      coffee: {
        files: ['<%= yeoman.app %>/scripts/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['newer:coffee:dist']
      },
      coffeeTest: {
        options: {spawn: false},
        files: ['test/spec/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['clean:liveTest','newer:coffee:test','copy:liveTest','karma:live'],
      },
      compass: {
        files: ['<%= yeoman.app %>/styles/**/*.{scss,sass}'],
        tasks: ['compass:server', 'bless', 'autoprefixer']
      },
      gruntfile: {
        files: ['Gruntfile.js']
      },
      styleconfig: {
        files: ['<%= yeoman.app %>/**/*.json'],
        tasks: ['shared_config']
      },
      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= yeoman.app %>/**/*.html',
          '.tmp/styles/**/*.css',
          '.tmp/scripts/**/*.js',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}',
          '<%= yeoman.app %>/scripts/theme_config.js'
        ],
        tasks: ['ngtemplates']
      }
    },

    ngdocs: {
      options: {
        html5Mode: true
      },
      all: ['.docs/scripts/**/*.js']
    },

    // The actual grunt server settings
    connect: {
      options: {
        port: 8999,
        // Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost',
        livereload: 35728
      },
      livereload: {
        options: {
          open: true,
          middleware: function (connect) {
            return [
              connect.static('.tmp'),
              connect().use(
                '/bower_components',
                connect.static('./bower_components')
              ),
              connect().use(
                '/app/styles',
                connect.static('./app/styles')
              ),
              connect.static(appConfig.app)
            ];
          }
        }
      },
      livereloadE2e: {
        options: {
          open: false,
          middleware: function (connect) {
            return [
              connect.static('.tmp'),
              connect().use(
                '/bower_components',
                connect.static('./bower_components')
              ),
              connect().use(
                '/app/styles',
                connect.static('./app/styles')
              ),
              connect.static(appConfig.app)
            ];
          }
        }
      },
      test: {
        options: {
          port: 9002,
          middleware: function (connect) {
            return [
              connect.static('.tmp'),
              connect.static('test'),
              connect().use(
                '/bower_components',
                connect.static('./bower_components')
              ),
              connect.static(appConfig.app)
            ];
          }
        }
      },
      dist: {
        options: {
          open: true,
          base: '<%= yeoman.dist %>'
        }
      }
    },

    protractor: {
      options: {
        configFile: "test/e2e/conf.js", // Default config file 
        keepAlive: true, // If false, the grunt process stops when the test fails. 
        noColor: false, // If true, protractor will not use colors in its output. 
        args: {
          // Arguments passed to the command 
        }
      },
      all: {},
    },

    ngconstant: {
      development: {
        options: {
          coffee: true,
          dest: '<%= yeoman.app %>/scripts/config.coffee',
          name: 'dcida20App.config',
          wrap: '"use strict";\n\n{%= __ngModule %}'
        },
        constants: {
          ENV: 'development',
          API_ENDPOINT: 'http://localhost:3000/api',
          API_PUBLIC: "http://localhost:3000",
          OAUTH_ENDPOINT: 'http://localhost:3000/oauth',
          WEBSOCKET_ENDPOINT: 'localhost:3000/websocket',
          WEBAPP_ENDPOINT: 'http://localhost:8999'
        }
      },
      staging: {
        options: {
          coffee: true,
          dest: '<%= yeoman.app %>/scripts/config.coffee',
          name: 'dcida20App.config',
          wrap: '"use strict";\n\n{%= __ngModule %}'
        },
        constants: {
          ENV: 'production',
          API_ENDPOINT: '{STAGING_ENDPOINT}/api',
          API_PUBLIC: '{STAGING_ENDPOINT}',
          OAUTH_ENDPOINT: '{STAGING_ENDPOINT}/oauth',
          WEBSOCKET_ENDPOINT: '{STAGING_WEBSOCKET_ENDPOINT}',
          WEBAPP_ENDPOINT: '{STAGING_WEBAPP_ENDPOINT}'
        }
      },
      heuristics: {
        options: {
          coffee: true,
          dest: '<%= yeoman.app %>/scripts/config.coffee',
          name: 'dcida20App.config',
          wrap: '"use strict";\n\n{%= __ngModule %}'
        },
        constants: {
          ENV: 'heuristics',
          API_ENDPOINT: '{HEURISTICS_ENDPOINT}/api',
          API_PUBLIC: '{HEURISTICS_ENDPOINT}',
          OAUTH_ENDPOINT: '{HEURISTICS_ENDPOINT}/oauth',
          WEBSOCKET_ENDPOINT: '{HEURISTICS_WEBSOCKET_ENDPOINT}',
          WEBAPP_ENDPOINT: '{HEURISTICS_WEBAPP_ENDPOINT}'
        }
      },
      production: {
        options: {
          coffee: true,
          dest: '<%= yeoman.app %>/scripts/config.coffee',
          name: 'dcida20App.config',
          wrap: '"use strict";\n\n{%= __ngModule %}'
        },
        constants: {
          ENV: 'production',
          API_ENDPOINT: '{PROD_ENDPOINT}/api',
          API_PUBLIC: '{PROD_ENDPOINT}',
          OAUTH_ENDPOINT: '{PROD_ENDPOINT}/oauth',
          WEBSOCKET_ENDPOINT: '{PROD_WEBSOCKET_ENDPOINT}',
          WEBAPP_ENDPOINT: '{PROD_WEBAPP_ENDPOINT}'
        }
      },
      newprod: {
        options: {
          coffee: true,
          dest: '<%= yeoman.app %>/scripts/config.coffee',
          name: 'dcida20App.config',
          wrap: '"use strict";\n\n{%= __ngModule %}'
        },
        constants: {
          ENV: 'production',
          API_ENDPOINT: '{NEWPROD_ENDPOINT}/api',
          API_PUBLIC: '{NEWPROD_ENDPOINT}',
          OAUTH_ENDPOINT: '{NEWPROD_ENDPOINT}/oauth',
          WEBSOCKET_ENDPOINT: '{NEWPROD_WEBSOCKET_ENDPOINT}',
          WEBAPP_ENDPOINT: '{NEWPROD_WEBAPP_ENDPOINT}'
        }
      }
    },


    // Make sure code styles are up to par and there are no obvious mistakes
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: {
        src: [
          'Gruntfile.js'
        ]
      }
    },

    // Empties folders to start fresh
    clean: {
      liveTest: {
        files: [{
          dot: true,
          src: ['test/karma.live.gen.conf.*']
        }]
      },
      docs: {
        files: [{
          dot: true,
          src: [
            '.docs',
            'docs/{,*/}*',
            '!docs/.git{,*/}*'
          ]
        }]
      },
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/{,*/}*',
            '!<%= yeoman.dist %>/.git{,*/}*'
          ]
        }]
      },
      server: '.tmp'
    },

    // Add vendor prefixed styles
    autoprefixer: {
      options: {
        browsers: ['last 1 version']
      },
      server: {
        options: {
          map: true,
        },
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '**/*.css',
          dest: '.tmp/styles/'
        }]
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '**/*.css',
          dest: '.tmp/styles/'
        }]
      }
    },

    // Automatically inject Bower components into the app
    wiredep: {
      app: {
        src: ['<%= yeoman.app %>/index.html'],
        ignorePath:  /\.\.\//
      },
      test: {
        devDependencies: true,
        src: '<%= karma.unit.configFile %>',
        ignorePath:  /\.\.\//,
        fileTypes:{
          coffee: {
            block: /(([\s\t]*)#\s*?bower:\s*?(\S*))(\n|\r|.)*?(#\s*endbower)/gi,
              detect: {
                js: /'(.*\.js)'/gi,
                coffee: /'(.*\.coffee)'/gi
              },
            replace: {
              js: '\'{{filePath}}\'',
              coffee: '\'{{filePath}}\''
            }
          }
          }
      },
      sass: {
        src: ['<%= yeoman.app %>/styles/**/*.{scss,sass}'],
        ignorePath: /(\.\.\/){1,2}bower_components\//
      }
    },

    // Compiles CoffeeScript to JavaScript
    coffee: {
      options: {
        sourceMap: true,
        sourceRoot: ''
      },
      docs: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '**/*.coffee',
          dest: '.docs/scripts',
          ext: '.js'
        }]
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '**/*.coffee',
          dest: '.tmp/scripts',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: 'test/spec',
          src: '{,*/}*.coffee',
          dest: '.tmp/spec',
          ext: '.js'
        }]
      }
    },

    // Compiles Sass to CSS and generates necessary files if requested
    compass: {
      options: {
        sassDir: '<%= yeoman.app %>/styles',
        cssDir: '.tmp/styles',
        generatedImagesDir: '.tmp/images/generated',
        imagesDir: '<%= yeoman.app %>/images',
        javascriptsDir: '<%= yeoman.app %>/scripts',
        fontsDir: '<%= yeoman.app %>/fonts',
        importPath: './bower_components',
        httpImagesPath: '/images',
        httpGeneratedImagesPath: '/images/generated',
        httpFontsPath: '/fonts',
        relativeAssets: false,
        assetCacheBuster: false,
        raw: 'Sass::Script::Number.precision = 10\n'
      },
      dist: {
        options: {
          generatedImagesDir: '<%= yeoman.dist %>/images/generated'
        }
      },
      server: {
        options: {
          sourcemap: true
        }
      }
    },

    bless: {
      css: {
        options: {},
        files: {
            '.tmp/styles/main_dist.css': '.tmp/styles/main.css'
        }
      }
    },

    // Renames files for browser caching purposes
    filerev: {
      dist: {
        src: [
          '<%= yeoman.dist %>/scripts/{,*/}*.js'
          //'<%= yeoman.dist %>/styles/{,*/}*.css'
        ]
      }
    },

    // Reads HTML for usemin blocks to enable smart builds that automatically
    // concat, minify and revision files. Creates configurations in memory so
    // additional tasks can operate on them
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>',
        flow: {
          html: {
            steps: {
              js: ['concat', 'uglifyjs'],
              css: ['cssmin']
            },
            post: {}
          }
        }
      }
    },

    // Performs rewrites based on filerev and the useminPrepare configuration
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      options: {
        assetsDirs: [
          '<%= yeoman.dist %>',
          '<%= yeoman.dist %>/images',
          '<%= yeoman.dist %>/styles'
        ]
      }
    },

    // The following *-min tasks will produce minified files in the dist folder
    // By default, your `index.html`'s <!-- Usemin block --> will take care of
    // minification. These next options are pre-configured if you do not wish
    // to use the Usemin blocks.
    cssmin: {
      options: {
        'processImport': false
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/styles',
          src: 'main_dist.css',
          dest: '<%= yeoman.dist %>/styles'
        },{
          expand: true,
          cwd: '.tmp/styles',
          src: 'main_dist.1.css',
          dest: '<%= yeoman.dist %>/styles'
        },{
          expand: true,
          cwd: '.tmp/styles',
          src: 'flat.css',
          dest: '<%= yeoman.dist %>/styles'
        }]
      }
    },
    // uglify: {
    //   dist: {
    //     files: {
    //       '<%= yeoman.dist %>/scripts/scripts.js': [
    //         '<%= yeoman.dist %>/scripts/scripts.js'
    //       ]
    //     }
    //   }
    // },
    // concat: {
    //   dist: {}
    // },

    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg,gif}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },

    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.svg',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },

    htmlmin: {
      dist: {
        options: {
          collapseWhitespace: true,
          conservativeCollapse: true,
          collapseBooleanAttributes: true,
          removeCommentsFromCDATA: true,
          removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: '**/*.html',
          dest: '<%= yeoman.dist %>'
        }]
      }
    },

    // ng-annotate tries to make the code safe for minification automatically
    // by using the Angular long form for dependency injection.
    ngAnnotate: {
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/concat/scripts',
          src: '*.js',
          dest: '.tmp/concat/scripts'
        }]
      }
    },

    // Replace Google CDN references
    cdnify: {
      dist: {
        html: ['<%= yeoman.dist %>/*.html']
      }
    },

    // Copies remaining files to places other tasks can use
    copy: {
      docs: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '.docs',
          src: [
            'scripts/**/*.coffee'
          ]
        }]
      },
      liveTest: {
        src: 'test/karma.live.conf.coffee',
        dest: 'test/karma.live.gen.conf.coffee',
        options: {
          process: function (content, srcpath) {
            console.log("I should have been redefined!");
            return content;
          }
        }
      },
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: [
            '*.{ico,png,txt}',
            '.htaccess',
            '*.html',
            'views/**/*.html',
            'images/{,*/}*.{webp}',
            'fonts/**/.*'
          ]
        }, {
          expand: true,
          cwd: '.tmp/images',
          dest: '<%= yeoman.dist %>/images',
          src: ['generated/*']
        }, {
          expand: true,
          cwd: '.',
          src: 'bower_components/font-awesome/fonts/*',
          dest: '<%= yeoman.dist %>'
        }, {
          expand: true,
          cwd: 'bower_components/jquery-ui/themes/base/images',
          src: '*',
          dest: '<%= yeoman.dist %>/styles/images'
        }, {
          expand: true,
          cwd: '<%- yeoman.app %>/fonts/lato',
          src: '*',
          dest: '<%= yeoman.dist %>/fonts/lato'
        }, {
          expand: true,
          cwd: '<%- yeoman.app %>/fonts/bootstrap',
          src: '*',
          dest: '<%= yeoman.dist %>/fonts/bootstrap'
        }]
        // }, {
        //   expand: true,
        //   cwd: '.tmp/styles',
        //   src: '*.css',
        //   dest: '<%= yeoman.dist %>/styles'
        // }]
      },
      styles: {
        expand: true,
        cwd: '<%= yeoman.app %>/styles',
        dest: '.tmp/styles/',
        src: '*.css'
      }
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      server: [
        'coffee:dist',
        'compass:server'
      ],
      test: [
        'coffee',
        'compass'
      ],
      dist: [
        'coffee',
        'compass:dist',
        'imagemin',
        'svgmin'
      ]
    },

    // Test settings
    karma: {
      unit: {
        configFile: 'test/karma.conf.coffee',
        singleRun: true
      },
      live: {
        configFile: 'test/karma.live.gen.conf.coffee',
        singleRun: true
      }
    },

    ngtemplates: {
      dcida20App: {
        cwd: '<%= yeoman.app %>',
        src: 'views/**/*.html',
        dest: '<%= yeoman.app %>/scripts/app.templates.js'
      },
      htmlmin: {
        collapseBooleanAttributes:      true,
        collapseWhitespace:             true,
        removeAttributeQuotes:          true,
        removeComments:                 true,
        removeEmptyAttributes:          true,
        removeRedundantAttributes:      true,
        removeScriptTypeAttributes:     true,
        removeStyleLinkTypeAttributes:  true
      }
    },

    shared_config: {
      default: {
        options: {
          name: "themeConfig",
          cssFormat: "dash",
          jsFormat: "uppercase",
          ngconstant: true
        },
        src: '<%= yeoman.app %>/theme_config.json',
        dest: [
          '<%= yeoman.app %>/scripts/theme_config.js',
          '<%= yeoman.app %>/styles/_theme_config.scss'
        ]
      }
    },

    run: {
      e2eTests: {
        options: {
          wait: true
        },
        cmd: 'node_modules/.bin/protractor-flake',
        args: [
          '--protractor-path=./node_modules/.bin/protractor',
          '--max-attempts=2',
          '--',
          'test/e2e/conf.js'
        ]
      }
    }

    // Istanbul coverage settings
    // env: {
    //   coverage: {
    //     APP_DIR_FOR_CODE_COVERAGE: "test/coverage/instrument/app/"
    //   }
    // },
    // instrument: {
    //   files: 'app/scripts/**/*.js',
    //   options: {
    //     lazy: true,
    //     basePath: "test/coverage/instrument/"
    //   }
    // },
    // mochaTest: {
    //   options: {
    //     reporter: "spec"
    //   },
    //   src: ['test/**/*.js']
    // },
    // storeCoverage: {
    //   options: {
    //     dir: "test/coverage/reports"
    //   }
    // },
    // makeReport: {
    //   src: "test/coverage/reports/**/*.json",
    //   options: {
    //     type: "lcov",
    //     dir: "test/coverage/reports",
    //     print: "detail"
    //   }
    // }
  });


  grunt.registerTask('serve', 'Compile then start a connect web server', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:server',
      'ngconstant:development',
      'wiredep',
      'concurrent:server',
      'bless',
      'autoprefixer:server',
      'connect:livereload',
      'shared_config',
      'ngtemplates',
      'watch'
    ]);
  });

  grunt.registerTask('server', 'DEPRECATED TASK. Use the "serve" task instead', function (target) {
    grunt.log.warn('The `server` task has been deprecated. Use `grunt serve` to start a server.');
    grunt.task.run(['serve:' + target]);
  });

  grunt.registerTask('test', [
    'clean:server',
    'wiredep',
    'shared_config',
    'ngconstant:development',
    'concurrent:test',
    'autoprefixer',
    'connect:test',
    'karma:unit'
  ]);

  grunt.registerTask('testLive', [
    'clean:server',
    'wiredep',
    'shared_config',
    'ngconstant:development',
    'concurrent:test',
    'autoprefixer',
    'watch:coffeeTest'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'ngconstant:staging',
    'wiredep',
    'useminPrepare',
    'concurrent:dist',
    'bless',
    'autoprefixer',
    'concat',
    'ngAnnotate',
    'cssmin:dist',
    'cssmin',
    'copy:dist',
    'cdnify',
    'uglify',
    'filerev',
    'usemin',
    'htmlmin'
  ]);

  grunt.registerTask('buildProduction', [
    'clean:dist',
    'ngconstant:production',
    'wiredep',
    'shared_config',
    'ngtemplates',
    'useminPrepare',
    'concurrent:dist',
    'bless',
    'autoprefixer',
    'concat',
    'ngAnnotate',
    'cssmin:dist',
    'cssmin',
    'copy:dist',
    'cdnify',
    'uglify',
    'filerev',
    'usemin',
    'htmlmin'
  ]);

  grunt.registerTask('buildNewprod', [
    'clean:dist',
    'ngconstant:newprod',
    'wiredep',
    'shared_config',
    'ngtemplates',
    'useminPrepare',
    'concurrent:dist',
    'bless',
    'autoprefixer',
    'concat',
    'ngAnnotate',
    'cssmin:dist',
    'cssmin',
    'copy:dist',
    'cdnify',
    'uglify',
    'filerev',
    'usemin',
    'htmlmin'
  ]);

  grunt.registerTask('buildHeuristics', [
    'clean:dist',
    'ngconstant:heuristics',
    'wiredep',
    'useminPrepare',
    'concurrent:dist',
    'bless',
    'autoprefixer',
    'concat',
    'ngAnnotate',
    'cssmin:dist',
    'cssmin',
    'copy:dist',
    'cdnify',
    'uglify',
    'filerev',
    'usemin',
    'htmlmin'
  ]);

  grunt.registerTask('docs', [
    'clean:docs',
    'ngconstant:production',
    'compass:dist',
    'coffee',
    'wiredep',
    'coffee:dist',
    'ngdocs'
  ]);

  grunt.registerTask('e2e-test', [
    'clean:server',
    'ngconstant:development',
    'wiredep',
    'shared_config',
    'ngtemplates',
    'concurrent:server',
    'autoprefixer:server',
    'connect:livereloadE2e',
    'run:e2eTests'
  ]);

  // grunt.registerTask('coverage', [
  //   'env:coverage', 
  //   'instrument', 
  //   'mochaTest',
  //   'storeCoverage', 
  //   'makeReport'
  // ]);

  grunt.registerTask('default', [
    'newer:jshint',
    'test',
    'build'
  ]);

  grunt.event.on('watch', function watchEventListener(action, filepath, target){

    // this handler handles ALL watch changes. Try to filter out ones from other watch tasks
    if (target == 'coffeeTest') handleJSHintSpec();

    // ---------------------
    function handleJSHintSpec() {
      if (action == 'deleted') return; // we don't need to run any tests when a file is deleted
      // this will probably fail if a watch task is triggered with multiple files at once
      // dynamically change the config
      console.log('Running ' + filepath + ' tests');
      console.log(grunt.config("copy.liveTest.options.process"))

      var newPath = 'test/karma.live.gen.conf.' + makeId(10) + '.coffee';

      grunt.config.set("copy.liveTest.dest", newPath);

      grunt.config.set("copy.liveTest.options.process", function (content, srcpath) {
        return content.replace('[FILE_PATH_TO_REPLACE]', filepath);
      }); 

      grunt.config.set("karma.live.configFile", newPath);

    }

    function makeId(length) {
       var result           = '';
       var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
       var charactersLength = characters.length;
       for ( var i = 0; i < length; i++ ) {
          result += characters.charAt(Math.floor(Math.random() * charactersLength));
       }
       return result;
    }

  });
};
