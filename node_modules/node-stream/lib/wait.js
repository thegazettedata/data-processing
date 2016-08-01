/* jshint node:true */

var waitObj = require('./waitObj.js');

function wait(stream, onEnd) {

    waitObj(stream, function(err, data) {

        if (err) {
            return onEnd(err);
        }

        onEnd(null, Buffer.concat(data.map(function(item) {
            return new Buffer(item);
        })));
    });
}

module.exports = wait;
