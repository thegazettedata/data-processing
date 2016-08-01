/* jshint node:true */

var wait = require('./wait.js');

function waitJson(stream, onEnd) {

    wait(stream, function(err, data) {

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

module.exports = waitJson;
