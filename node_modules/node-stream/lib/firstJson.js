/* jshint node:true */

var first = require('./first.js');

function firstJson(stream, onEnd) {

    first(stream, function(err, data) {

        if (err) {
            return onEnd(err);
        }

        try {
            data = JSON.parse(data);
        } catch(e) {
            return onEnd(e);
        }

        onEnd(null, data);
    });
}

module.exports = firstJson;
