/* jshint node:true */

var split = require('split');

var first = require('./lib/first.js');
var firstObj = require('./lib/firstObj.js');
var firstJson = require('./lib/firstJson.js');

var forEach = require('./lib/forEach.js');
var forEachObj = require('./lib/forEachObj.js');
var forEachJson = require('./lib/forEachJson.js');

var wait = require('./lib/wait.js');
var waitObj = require('./lib/waitObj.js');
var waitJson = require('./lib/waitJson.js');

first.obj = firstObj;
first.json = firstJson;

forEach.obj = forEachObj;
forEach.json = forEachJson;

wait.obj = waitObj;
wait.json = waitJson;

module.exports = {
    split: split,
    first: first,
    forEach: forEach,
    wait: wait
};
