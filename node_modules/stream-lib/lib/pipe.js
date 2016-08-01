/*jslint node:true*/

'use strict';

var Transform = require('stream').Transform;

/**
 * Just pipe the chunk to the next stream.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Transform}
 */
var Pipe = function Pipe() {
    Transform.apply(this, arguments);
};
/*jslint unparam: true*/
Pipe.prototype = {
    '__proto__': Transform.prototype,

    '_transform': function (chunk, encoding, next) {
        this.push(chunk);
        return next();
    }
};
/*jslint unparam: false*/

/**
 * A hopper for multiple streams. It can combine multiple streams, but not in order like concat, and
 * finish stream, when all added streams are done.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib.Pipe
 * @constructor
 * @augments streamLib.Pipe
 */
Pipe.Hopper = function () {
    Pipe.apply(this, arguments);

    this.on('pipe', function () {
        this.openHops += 1;
    });
    this.on('unpipe', this.end);
};
Pipe.Hopper.prototype = {
    '__proto__': Pipe.prototype,

    '_end': function () {
        return Pipe.prototype.end.apply(this, arguments);
    },
    end: function () {
        this.openHops -= 1;
        if (this.openHops === 0) {
            return Pipe.prototype.end.apply(this);
        }
    },
    openHops: 0
};

/**
 * A chainable pipe. You can chain this pipe before or after a (chainable) pipe.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Chain = function () {
    Pipe.apply(this, arguments);
};
Pipe.Chain.prototype = {
    '__proto__': Pipe.prototype,


    /**
     * Enhance a stream to a chainable one
     * @private
     * @param {stream} chain
     */
    enhanceForeignStream: function (chain) {
        if (chain.readable) {
            chain.chainAfter = chain.chainAfter || Pipe.Chain.prototype.chainAfter;
            chain.nextChain = chain.nextChain || Pipe.Chain.prototype.nextChain;
        }
        if (chain.writable) { // Duplex
            chain.chainBefore = chain.chainBefore || Pipe.Chain.prototype.chainBefore;
            chain.previousChain = chain.previousChain || Pipe.Chain.prototype.previousChain;
        }

        chain.autoEnhance = true;

        chain.enhanceForeignStream = chain.enhanceForeignStream || Pipe.Chain.prototype.enhanceForeignStream;

    },
    /**
     * Chain this chain before the stream given as parameter
     * @param {stream.Writable|stream.Transform|stream.Duplex} chain - Next stream
     * @returns {Pipe.Chain}
     */
    chainBefore: function (chain) {
        if (chain.previousChain) {
            chain.previousChain.unpipe(chain);
            chain.previousChain.pipe(this);

            chain.previousChain.nextChain = this;

        }
        if (this.autoEnhance) {
            this.enhanceForeignStream(chain);
        }

        this.pipe(chain);
        chain.previousChain = this;
        this.nextChain = chain;
        return this;
    },
    /**
     * Chain this chain after the stream given as parameter
     * @param {stream.Readable|stream.Transform|stream.Duplex} chain - Parent stream
     * @returns {Pipe.Chain}
     */
    chainAfter: function (chain) {
        if (chain.nextChain) {
            chain.unpipe(chain.nextChain);

            chain.nextChain.previousChain = this;

        }
        if (this.autoEnhance) {
            this.enhanceForeignStream(chain);
        }

        chain.pipe(this);
        chain.nextChain = this;
        this.previousChain = chain;
    },

    previousChain: null,
    nextChain: null,
    autoEnhance: true
};

/**
 * Pipe with delay
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Delay = function () {
    Transform.apply(this, arguments);
};
Pipe.Delay.prototype = {
    '__proto__': Transform.prototype,

    '_transform': function () {
        var args = arguments;
        setTimeout(function () {
            /*jslint nomen: true*/
            Pipe.prototype._transform.apply(this, args);
            /*jslint nomen: false*/
        }.bind(this), this.delay);
    },

    /**
     * Delay in milliseconds
     * @type {number}
     */
    delay: 0
};
/**
 * Make a stream async with process.nextTick
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Async = function () {
    Transform.apply(this, arguments);
};
Pipe.Async.prototype = {
    '__proto__': Transform.prototype,

    '_transform': function () {
        var args = arguments;
        process.nextTick(function () {
            /*jslint nomen: true*/
            Pipe.prototype._transform.apply(this, args);
            /*jslint nomen: false*/
        }.bind(this));
    }
};

/**
 * Give the possibility to ignore incoming chunks (unpiped data will be lost)
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Tap = function () {
    Pipe.apply(this, arguments);
};

/*jslint unparam: true*/
Pipe.Tap.prototype = {
    '__proto__': Pipe.prototype,

    '_transform': function (chunk, encoding, next) {
        if (this.locked) {
            return next();
        }

        /*jslint nomen: true*/
        return Pipe.prototype._transform.apply(this, arguments);
    },
    locked: false,

    lock: function () {
        this.locked = true;
        return this;
    },
    unlock: function () {
        this.locked = false;
        return this;
    },
    toggle: function () {
        if (this.locked) {
            return this.unlock();
        }
        return this.lock();
    }
};
/*jslint unparam: false*/

/**
 * Give the possibility to stop flowing incoming chunks (stopping will block the stream)
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Gate = function () {
    Pipe.apply(this, arguments);
};
Pipe.Gate.prototype = {
    '__proto__': Pipe.prototype,

    '_transform': function () {
        if (this.locked) {
            this.lastArguments = arguments;
            return;
        }
        this.lastArguments = null;

        /*jslint nomen: true*/
        return Pipe.prototype._transform.apply(this, arguments);
    },

    lastArguments: null,
    locked: false,

    lock: function () {
        this.locked = true;
        return this;
    },
    unlock: function () {
        this.locked = false;
        if (this.lastArguments) {
            /*jslint nomen: true*/
            this._transform.apply(this, this.lastArguments);
            /*jslint nomen: false*/
        }
        return this;
    },
    toggle: function () {
        if (this.locked) {
            return this.unlock();
        }
        return this.lock();
    }
};

/**
 * Keep track of piped chunks and disallow chunks from passing this stream twice
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Once = function () {
    Pipe.apply(this, arguments);
    this.knownChunks = [];
};

/*jslint unparam: true*/
Pipe.Once.prototype = {
    '__proto__': Pipe.prototype,

    '_transform': function (chunk, encoding, next) {

        if (this.knownChunks.indexOf(chunk) !== -1) {
            if (this.freeing) {
                this.knownChunks.splice(this.knownChunks.indexOf(chunk), 1);
            }
            return next();
        }
        this.knownChunks.push(chunk);

        /*jslint nomen: true*/
        Pipe.prototype._transform.apply(this, arguments);
        /*jslint nomen: false*/
    },

    /**
     * Array of known chunks
     * @type {Array}
     */
    knownChunks: [],
    /**
     * Should the pipe remove the chunks from known list that passes the stream twice?
     * @type {boolean}
     */
    freeing: true
};
/*jslint unparam: false*/

/**
 * A pipe that does not end. It will keep alive, like a zombie
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.Zombie = function () {
    Pipe.apply(this, arguments);
};
Pipe.Zombie.prototype = {
    '__proto__': Pipe.prototype,

    /**
     * The original end method, that is able to end the stream
     * @returns {*|number}
     */
    '_end': function () {
        return Pipe.prototype.end.apply(this, arguments);
    },
    end: function () {
        return false;
    }
};

/**
 * Create a pipe forced in objectMode
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @param opts
 * @constructor
 * @memberOf streamLib.Pipe
 * @augments streamLib.Pipe
 */
Pipe.ObjectMode = function (opts) {
    var args, i;
    if (typeof opts === 'object') {
        args = arguments;
    } else {
        args = [{}];
        for (i = 1; i < arguments.length; i += 1) {
            args.push(arguments[i]);
        }
    }
    args[0].objectMode = true;
    Pipe.apply(this, args);
};

Pipe.ObjectMode.prototype = {
    '__proto__': Pipe.prototype,
    objectMode: true
};

// IDEAS: Multicore like a multicore in audio, a stream full ob stream objects

module.exports = Pipe;
