/* jshint node:true */

function waitObj(stream, onEnd) {
    var data = [];

    function end(err) {

        if (err) {
            return onEnd(err);
        }

        onEnd(null, data);
    }

    stream.on('data', function(chunk) {
        data.push(chunk);
    });
    stream.on('error', end);
    stream.on('end', end);
}

module.exports = waitObj;
