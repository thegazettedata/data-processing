/*jslint node:true*/

'use strict';

var Duplex = require('stream').Duplex;

/**
 * Record a stream and repeat this as sequence
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Duplex}
 */
var Sequencer = function () {
    Duplex.apply(this, arguments);
    this.clearSequence();
    this.startRecording();
};
/*jslint unparam: true*/
Sequencer.prototype = {
    '__proto__': Duplex.prototype,

    '_read': function () {
        if (this.sequence.length === this.position) {
            this.position = 0;
        }

        this.push(this.sequence[this.position]);

        this.position += 1;
    },
    '_write': function (chunk, encoding, next) {
        if (this.isRecording) {
            this.sequence.push(chunk);
        }
        return next();
    },

    '_end': function () {
        this.push(null);
        return Duplex.prototype.end.apply(this, arguments);
    },
    end: function () {
        this.stopRecording();
        return false;
    },
    /**
     * Start recording sequence
     * @returns {Sequencer}
     */
    startRecording: function () {
        this.isRecording = true;
        return this;
    },
    /**
     * Stop recording sequence
     * @returns {Sequencer}
     */
    stopRecording: function () {
        this.isRecording = false;
        return this;
    },
    /**
     * Delete recorded sequence
     * @returns {Sequencer}
     */
    clearSequence: function () {
        this.sequence = [];
        return this;
    },

    /**
     * is
     * @type {Boolean}
     */
    isRecording: true,
    /**
     * @type {chunk[]}
     */
    sequence: [],
    /**
     * @type {number}
     */
    position: 0
};
/*jslint unparam: false*/

module.exports = Sequencer;
