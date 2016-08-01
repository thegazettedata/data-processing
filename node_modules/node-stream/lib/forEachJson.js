/* jshint node:true */

var forEach = require('./forEach.js');

function forEachJson(stream, onData, onEnd) {

    forEach(stream, function(chunk) {

        try {
            chunk = JSON.parse(chunk);
        } catch(e) {
            return stream.emit('error', e);
        }

        onData(chunk);
    }, onEnd);
}

module.exports = forEachJson;
