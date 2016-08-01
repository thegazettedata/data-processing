/*jslint node:true*/

'use strict';

var Hopper = require('./pipe').Hopper;

/**
 * Concat multiple readable streams in order
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {streamLib.Pipe.Hopper}
 */
var Concat = function () {
    Hopper.apply(this, arguments);

    this.on('pipe', function (stream) {
        this.pending.push(stream);

        if (this.pending.length > 1) {
            stream.pause();
        }
    });
    this.on('unpipe', function (stream) {
        var index = this.pending.indexOf(stream);

        if (index !== -1) {
            this.pending.splice(index, 1);
        }
        if (index === 0 && this.pending[0]) {
            this.pending[0].resume();
        }
    });
};

Concat.prototype = {
    '__proto__': Hopper.prototype,

    /**
     * Pending streams
     * @type {stream.Readable[]|stream.Duplex[]|stream.Transform[]}
     */
    pending: []
};

module.exports = Concat;
