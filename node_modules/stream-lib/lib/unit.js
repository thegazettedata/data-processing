/*jslint node:true*/

'use strict';

var Duplex = require('stream').Duplex;

/**
 * Grouping multiple pipes into a unit.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Duplex}
 */
var Unit = function () {
    Duplex.apply(this, arguments);

    this.on('finish', function () {
        if (this.writableUnit) {
            this.writableUnit.end();
        }
    });
};
/*jslint unparam: true*/
Unit.prototype = {
    '__proto__': Duplex.prototype,

    '_write': function (chunk, encoding, next) {
        if (!this.writableUnit) {
            return next(new Error('Unit was not linked to a writeable unit'));
        }
        /*jslint nomen: true*/
        return this.writableUnit._write.apply(this.writableUnit, arguments);
    },
    '_read': function (bytes) {
        if (!this.readableUnit) {
            throw new Error('Unit was not linked to a readable unit');
        }
        /*jslint nomen: true*/
        return this.readableUnit._read.apply(this.readableUnit, arguments);
    },

    /**
     * Set a writable stream for this unit
     * @param {stream.Writable|stream.Duplex|stream.Transform} stream - Use this stream as writable stream
     * @returns {Unit}
     */
    setWritableStream: function (stream) {
        this.writableUnit = stream;
        return this;
    },
    /**
     * Set a readable stream for this unit
     * @param {stream.Readable|stream.Duplex|stream.Transform} stream - Use this stream as readable stream
     * @returns {Unit}
     */
    setReadableStream: function (stream) {
        var self = this;
        stream.on('data', function (chunk) {
            self.push(chunk);
        });
        stream.on('end', function () {
            self.push(null);
        });
        this.readableUnit = stream;
        return this;
    },

    /**
     * @private
     */
    requestedRead: false,
    /**
     * @private
     */
    isReadable: false,
    /**
     * Writable stream of this unit
     * @type {stream.Writable|stream.Duplex|stream.Transform}
     */
    writableUnit: null,
    /**
     * Readable stream of this unit
     * @type {stream.Readable|stream.Duplex|stream.Transform}
     */
    readableUnit: null
};
/*jslint unparam: false*/

module.exports = Unit;
