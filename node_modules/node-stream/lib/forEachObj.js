/* jshint node:true */

function forEachObj(stream, onData, onEnd) {
    stream.on('data', onData);
    stream.on('error', onEnd);
    stream.on('end', onEnd);
}

module.exports = forEachObj;
