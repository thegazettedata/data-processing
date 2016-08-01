/*jslint node: true*/

'use strict';
var Unit = require('./unit');
var Tap = require('./pipe').Tap;
var Gate = require('./pipe').Gate;


/**
 * A sluice for streams. It works like a pipe with two gates. If the first gate is closed incoming chunks dismiss
 * this stream. If the second gate is closed chunks get buffered, but not send to next stream.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {streamLib.Unit}
 * @todo tests do not work this module should be refactored
 * @private
 */
var Sluice = function () {
    Unit.apply(this, arguments);

    this.tap = new Tap();
    this.gate = new Gate();

    this.tap
        .pipe(this.gate);

    this.setWritableStream(this.tap);
    this.setReadableStream(this.gate);


};
/*jslint unparam: true*/
Sluice.prototype = {
    '__proto__': Unit.prototype,

    '_read': function () {
        if (!this.flowOut) {
            return;
        }
        while (this.buffer.length) {
            this.push(this.buffer.shift());
        }
    },
    '_write': function (chunk, encoding, next) {
        if (!this.flowIn) {
            next();
        }
        this.buffer.push(chunk);
        /*jslint nomen: true*/
        this._read();
        /*jslint nomen: false*/
    },

    /**
     * Allow incoming chunks
     * @returns {Sluice}
     */
    openInlet: function () {
        this.tap.unlock();
        return this;
    },
    /**
     * Deny incoming chunks
     * @returns {Sluice}
     */
    closeInlet: function () {
        this.tap.lock();
        return this;
    },
    /**
     * Allow outgoing chunks
     * @returns {Sluice}
     */
    openOutlet: function () {
        this.gate.unlock();
        return this;
    },
    /**
     * Deny outgoing chunks
     * @returns {Sluice}
     */
    closeOutlet: function () {
        this.gate.lock();
        return this;
    },
    /**
     * Collect chunks in buffer but do not send them to next stream
     * @returns {Sluice}
     */
    pourIn: function () {
        return this.closeOutlet().openInlet();
    },
    /**
     * Dismiss incoming chunks, but clear buffer by sending to next stream
     * @returns {Sluice}
     */
    pourOut: function () {
        return this.openOutlet().closeInlet();
    },
    /**
     * All gates open, work as a normal pipe
     * @returns {Sluice}
     */
    fullFlow: function () {
        return this.openOutlet().openInlet();
    },
    /**
     * Dismiss incoming chunks and do not send any buffered data to next stream
     * @returns {Sluice}
     */
    freeze: function () {
        return this.closeOutlet().closeInlet();
    },

    /**
     * Buffer of chunks
     * @type {Buffer[]|Array}
     */
    buffer: [],

    /**
     * Allow chunks to flow-in?
     * @type {Boolean}
     */
    flowIn: true,
    /**
     * Allow chunks to flow-out?
     * @type {Boolean}
     */
    flowOut: true
};
/*jslint unparam: false*/

module.exports = Sluice;
