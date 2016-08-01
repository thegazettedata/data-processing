/* jshint node:true */

var forEachObj = require('./forEachObj.js');

function forEach(stream, onData, onEnd) {

    forEachObj(stream, function(chunk) {
        onData(new Buffer(chunk));
    }, onEnd);
}

module.exports = forEach;
