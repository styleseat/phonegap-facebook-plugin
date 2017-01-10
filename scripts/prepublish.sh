#!/usr/bin/env node

'use strict';

var BUILD_DIR = './dist';
var PLUGIN_NAME = 'facebookConnectPlugin';
var PLUGIN_FILENAME = PLUGIN_NAME + '.js';
var MINIFIED_FILENAME = PLUGIN_NAME + '.min.js';

var fs = require('fs');
var path = require('path');
var requirejs = require('requirejs');
var rimraf = require('rimraf');
var uglifyjs = require('uglify-js');

rimraf.sync(BUILD_DIR);
fs.mkdirSync(BUILD_DIR);

requirejs.optimize({
  baseUrl: '.',
  name: PLUGIN_NAME,
  out: path.join(BUILD_DIR, PLUGIN_FILENAME),
  paths: {
    [PLUGIN_NAME]: path.join('www', 'facebook-browser')
  },
  shim: {
    [PLUGIN_NAME]: {
      exports: PLUGIN_NAME
    }
  },
  wrap: {
    start: '(function(exports, define) { this.' + PLUGIN_NAME + ' = exports; ',
    end: '})({}, function(symbol, builder) { return (window[symbol] = window[symbol] || builder()); });'
  },
  optimize: 'none'
}, function(buildResult) {
  var minified = uglifyjs.minify(
    [path.join(BUILD_DIR, PLUGIN_FILENAME)],
    {
      outSourceMap: MINIFIED_FILENAME + ".map",
      outFileName: MINIFIED_FILENAME
  }  );
  fs.writeFileSync(path.join(BUILD_DIR, MINIFIED_FILENAME), minified.code)
  fs.writeFileSync(path.join(BUILD_DIR, MINIFIED_FILENAME + '.map'), minified.map);
});

