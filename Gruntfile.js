
module.exports = function(grunt) {



  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    simplemocha: {
      options: {
        globals: ['should'],
        timeout: 3000,
        ignoreLeaks: false,
        ui: 'bdd',
        reporter: 'spec'
      },
      all: {
        src: 'test/*.coffee',
      }
    },

    coffee: {
      all: {
        files: {
          'lib/beautiful-lies.js': ['src/beautiful-lies.coffee'],
          'lib/macros.js':         ['src/macros.coffee'],
        }
      }
    },

    concat: {
      options: {
        banner:
          '// Beautiful Lies\n' +
          '// version: <%= pkg.version %>\n' +
          '// author: <%= pkg.author.name %> <<%= pkg.author.email %>> <%= pkg.author.url %>\n' +
          '// license: <%= pkg.license %>'
      },
      dist: {
        src: ['lib/beautiful-lies.js'],
        dest: 'lib/beautiful-lies.js',
      }

    },


  });

    grunt.loadNpmTasks('grunt-simple-mocha');
  grunt.loadNpmTasks('grunt-bump');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');

  grunt.registerTask('build', [ 'simplemocha', 'concat:dist',  'coffee',  ]);
  // For some UNGODLY reason, simplemocha has to be at the end or grunt will break,
  // looking for an indexOf method on the lie object.
};
