var gulp = require('gulp');
var rename = require("gulp-rename");

gulp.task('deps', function() {
  gulp.src(['./deps/js/angular/angular.js',
            './deps/js/snapjs/snap.js',
            './deps/js/spin.js/spin.js',
            './deps/js/',
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
});


gulp.task('default', ['deps']);
