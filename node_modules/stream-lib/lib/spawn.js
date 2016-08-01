/*jslint node:true*/

'use strict';

var Duplex = require('stream').Duplex;

var spawn = require('child_process').spawn;

/**
 * Spawn a childprocess as piped through stdin and stdout.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Duplex}
 */
var Spawn = function () {
    Duplex.apply(this, arguments);
};

var privatePump = function () {
    if (this.isDuplexReadable && this.isSpawnReadable) {
        this.isDuplexReadable = false;
        this.isSpawnReadable = false;

        this.push(this.cmd.stdout.read());
        this.cmd.stdout.read(0);
    }
};

/*jslint unparam: true*/
Spawn.prototype = {
    '__proto__': Duplex.prototype,

    '_write': function (chunk, encoding, next) {
        if (!this.cmd) {
            console.warn('Write into spawn before spawning it! Potentially data loss!');
            return next();
        }
        this.cmd.stdin.write(chunk);
        next();
    },
    '_read': function () {
        this.isDuplexReadable = true;
        privatePump.apply(this);
    },

    /**
     * Spawn a process and set stdin to writable stream and stdout to readable stream.
     *
     * Please take a look at node.js-API for further information.
     *
     * @param {string} command - Command name that shoul be executed
     * @param {string[]} [params] - Parameters to set in spawned process
     * @param {{}} [opts] - Optional spawn settings
     */
    spawn: function (command, params, opts) {
        var self = this;
        this.cmd = spawn(command, params, opts);

        this.cmd.stdout.on('readable', function () {
            self.isSpawnReadable = true;
            privatePump.apply(self);
        });
        this.cmd.stdout.on('end', function () {
            self.push(null);
        });
        this.on('finish', function () {
            this.cmd.stdin.end();
        });

    },

    /**
     * Original spawn
     * @type {null|*}
     */
    cmd: null,
    /**
     * Is the spawned process readable?
     * @private
     */
    isSpawnReadable: false,
    /**
     * Is this stream requesting a chunk?
     * @private
     */
    isDuplexReadable: false
};
/*jslint unparam: false*/

// IDEAS: spawn stderr

module.exports = Spawn;