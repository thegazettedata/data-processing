/*jslint node:true*/

'use strict';

var Transform = require('stream').Transform;


/**
 * Send chunks on beat.
 * @constructor
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib
 * @augments {stream.Transform}
 * @todo is not tested
 * @private
 */
var Beat = function () {
    Transform.apply(this, arguments);

};
Beat.prototype = {
    '__proto__': Transform.prototype,

    '_transform': function () {
        this.lastArguments = arguments;
        return true;
    },

    setBps: function (bps) {
        return this.setBpm(bps * 60);
    },
    setBpm: function (bpm) {
        this.delay = Math.floor((60000 / bpm) + 0.5);
        return this;
    },

    start: function () {
        var self = this,
            pump = function () {
                if (!self.lastArguments) {
                    return;
                }

                while (Date.now() < self.lastBeat + self.delay) { // precise
                    // wait;
                }
                self.push(self.lastArguments[0]); // chunk
                self.lastArguments[2]();          // next()
                self.start();
            },
            timeDifference;

        timeDifference = ((this.lastBeat || Date.now()) + this.delay) - Date.now();

        this.lastBeat = Date.now();

        this.timeout = setTimeout(pump, timeDifference - (parseInt(this.precise, 10) || 0));
        return this;
    },
    stop: function () {
        clearTimeout(this.timeout);
        this.timeout = null;
        this.lastBeat = null;
        return this;
    },

    delay: 0,
    precise: false,
    lastBeat: null,
    even: true,
    lastArguments: null,
    timeout: null
};

// IDEA: Make a Buffered Beat that sends multiple before collected chunks

module.exports = Beat;
