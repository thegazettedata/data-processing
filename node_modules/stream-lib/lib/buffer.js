/*jslint node:true*/

'use strict';

var Duplex = require('stream').Duplex;

/**
 * Buffers a stream in memory.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Duplex}
 */
var BufferStream = function BufferStream() {
    Duplex.apply(this, arguments);

    this.on('finish', function () {
        this.push(null);
    });

};
/*jslint unparam: true*/
BufferStream.prototype = {
    '__proto__': Duplex.prototype,

    '_read': function () {
        return true;
    },
    '_write': function (chunk, encoding, next) {
        this.push(chunk);
        next();
    }
};
/*jslint unparam: false*/

module.exports = BufferStream;
