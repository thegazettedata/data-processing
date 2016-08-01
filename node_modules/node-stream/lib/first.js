/* jshint node:true */

var firstObj = require('./firstObj.js');

function first(stream, onEnd) {

    firstObj(stream, function(err, data) {

        if (err) {
            return onEnd(err);
        }

        onEnd(null, new Buffer(data));
    });
}

module.exports = first;
