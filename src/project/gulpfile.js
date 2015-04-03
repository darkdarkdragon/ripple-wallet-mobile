'use strict';

var gulp = require('gulp');
var rename = require("gulp-rename");

var $ = require('gulp-load-plugins')({
  pattern: ['gulp-*', 'del']
});


var buildDirPath = 'www';

// Less
gulp.task('less', function () {
  return gulp.src('src/less/ripple/web.less')
    .pipe($.less({
      paths: ['src/less']
    }))
    .pipe(gulp.dest(buildDirPath + '/css'));
});

gulp.task('deps', function() {
  gulp.src(['./deps/js/angular/angular.js',
            './deps/js/snapjs/snap.js',
            './deps/js/spin.js/spin.js',
            './deps/js/jquery/dist/jquery.js',
            './deps/js/',
  ], { read: true }).pipe(gulp.dest('./www/js'));
  gulp.src('./deps/js/angular-messages/index.js', { read: true })
    .pipe(rename("angular-messages.js"))
    .pipe(gulp.dest('./www/js'));
  gulp.src('./deps/js/angular-route/index.js', { read: true })
    .pipe(rename("angular-route.js"))
    .pipe(gulp.dest('./www/js'));
  gulp.src('./deps/js/angular-touch/index.js', { read: true })
    .pipe(rename("angular-touch.js"))
    .pipe(gulp.dest('./www/js'));
  gulp.src('deps/js/mobile-angular-ui/dist/**', { base: 'deps/js/mobile-angular-ui/dist' })
    .pipe(gulp.dest('./www'));
  gulp.src('./src/*.html')
    .pipe(gulp.dest('./www'));
  gulp.src('./img/**/*')
    .pipe(gulp.dest('./www/img'));
});


gulp.task('default', ['less', 'deps']);
