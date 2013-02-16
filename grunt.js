module.exports = function(grunt) {
  grunt.initConfig({
    pkg: '<json:package.json>',
    meta: {
      banner:
        '// Beautiful Lies\n' +
        '// version: <%= pkg.version %>\n' +
        '// author: <%= pkg.author.name %> <<%= pkg.author.email %>> <%= pkg.author.url %>\n' +
        '// license: <%= pkg.license %>'
    },
    simplemocha: {
      all: {
        src: 'test/**/*.coffee',
        options: {
          globals: ['should'],
          timeout: 3000,
          ui: 'bdd',
          reporter: 'spec'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-simple-mocha');
  grunt.loadNpmTasks('grunt-bump');

  grunt.registerTask('compile', 'Compiles CoffeeScript source into JavaScript.', function(){
    var coffee = require('coffee-script');
    var js = coffee.compile(grunt.file.read('src/beautiful-lies.coffee'));
    var banner = grunt.task.directive('<banner:meta.banner>', function() { return null; });
    if (js) grunt.file.write('lib/beautiful-lies.js', banner + js);

    js = coffee.compile(grunt.file.read('src/macros.coffee'));
    if (js) grunt.file.write('lib/macros.js', js);
  });

  grunt.registerTask('build', 'simplemocha compile');
};
