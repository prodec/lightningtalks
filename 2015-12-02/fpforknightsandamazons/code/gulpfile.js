var gulp = require("gulp");
var gulpBabel = require("gulp-babel");
var babel = require("babel/register");
var jsdoc = require("gulp-jsdoc");
var mocha = require("gulp-mocha");

gulp.task("build", function() {
  return gulp.src("src/**/*.js")
    .pipe(gulpBabel())
    .pipe(gulp.dest("dist"));
});

gulp.task("default", ["build"]);

gulp.task("docs", function() {
  return gulp.src("src/**/*.js")
    .pipe(babel())
    .pipe(jsdoc("doc"));
});

gulp.task("watch-test", function() {
  gulp.watch(["src/**/*.js", "test/**/*.js"], ["test"]);
});
