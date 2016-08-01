/*jslint node:true*/

'use strict';

// IDEA: Measure.Md5 <- md5 of a stream (same with sha1 etc. Maybe make crypto-measure first...)

var Pipe = require('./pipe');
var Readable = require('stream').Readable;

/**
 * Measure piped data
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Readable}
 */
var Measure = function () {
    Readable.call(this, {objectMode: true});
};
/*jslint unparam: true*/
Measure.prototype = {
    '__proto__': Readable.prototype,

    '_read': function () {
        return true;
    }
};

/**
 * A measure stream with a pipe for measuring
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @param {{}} [opts] - Options for this stream and measure pipe
 * @memberOf streamLib.Measure
 * @constructor
 */
Measure.SinglePipe = function (opts) {
    Measure.apply(this, arguments);
    var self = this;

    this.measurePipe = new Pipe(opts);

    this.measurePipe.on('end', function () {
        self.push(null);
    });

};
Measure.SinglePipe.prototype = {
    '__proto__': Measure.prototype,

    /**
     * @type {streamLib.Pipe}
     */
    measurePipe: null
};
/**
 * A measure stream with inlet and a outlet pipe for measuring
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @param {{}} [opts] - Options for this stream and measure pipe
 * @memberOf streamLib.Measure
 * @augments streamLib.Measure
 * @constructor
 */
Measure.InletOutlet = function (opts) {
    Measure.apply(this, arguments);

    var self = this;

    this.measureInlet = new Pipe(opts);
    this.measureOutlet = new Pipe(opts);


    this.measureOutlet.on('end', function () {
        self.push(null);
    });
};
Measure.InletOutlet.prototype = {
    '__proto__': Measure.prototype,

    /**
     * @type {streamLib.Pipe}
     */
    measureInlet: null,
    /**
     * @type {streamLib.Pipe}
     */
    measureOutlet: null
};

/**
 * A measure stream that count Bufferlength and chunks from a measure pipe
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib.Measure
 * @augments streamLib.Measure.SinglePipe
 * @constructor
 */
Measure.Chunk = function () {
    var self = this;

    Measure.SinglePipe.apply(this, arguments);

    /*jslint nomen: true*/
    this.measurePipe._transform = function (chunk) {
        if (typeof chunk.length === 'number') {
            self.push({timestamp: Date.now(), length: chunk.length});
        } else {
            self.push({timestamp: Date.now()});
        }
        return Pipe.prototype._transform.apply(this, arguments);
    };
};
Measure.Chunk.prototype = {
    '__proto__': Measure.SinglePipe.prototype
};


/**
 * A measure stream that calculate capacity of buffer length and chunks between two measure pipes
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib.Measure
 * @augments streamLib.Measure.InletOutlet
 * @constructor
 */
Measure.Capacity = function () {
    Measure.InletOutlet.apply(this, arguments);
    var chunkCapacity = 0,
        bufferCapacity = 0,
        self = this;

    /*jslint nomen: true*/
    this.measureInlet._transform = function (chunk) {
        if (typeof chunk.length === 'number') {
            bufferCapacity += chunk.length;
        }
        chunkCapacity += 1;
        self.push({timestamp: Date.now(), capacity: {chunks: chunkCapacity, buffer: bufferCapacity}});
        return Pipe.prototype._transform.apply(this, arguments);
    };
    this.measureOutlet._transform = function (chunk) {
        if (typeof chunk.length === 'number') {
            bufferCapacity -= chunk.length;
        }
        chunkCapacity -= 1;
        self.push({timestamp: Date.now(), capacity: {chunks: chunkCapacity, buffer: bufferCapacity}});
        return Pipe.prototype._transform.apply(this, arguments);
    };
};
Measure.Capacity.prototype = {
    '__proto__': Measure.InletOutlet.prototype
};


/**
 * A measure stream that calculates the latency between two measure pipes
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib.Measure
 * @augments streamLib.Measure.InletOutlet
 * @constructor
 */
Measure.Latency = function () {
    Measure.InletOutlet.apply(this, arguments);

    var chunks = [],
        self = this;

    /*jslint nomen: true*/
    this.measureInlet._transform = function (chunk) {
        chunks.push({chunk: chunk, timestamp: Date.now()});
        /*jslint nomen: true*/
        return Pipe.prototype._transform.apply(self.measureInlet, arguments);
    };
    this.measureOutlet._transform = function (chunk) {
        /*jslint nomen: false*/
        var timestamp = Date.now(),
            i;

        for (i = 0; i < chunks.length; i += 1) {
            if (chunks[i].chunk === chunk) {
                self.push({latency: timestamp - chunks[i].timestamp});
                chunks.splice(i, 1);
                /*jslint nomen: true*/
                return Pipe.prototype._transform.apply(self.measureOutlet, arguments);
            }
        }

        /*jslint nomen: true*/
        return Pipe.prototype._transform.apply(self.measureOutlet, arguments);
    };
    /*jslint nomen: false*/
};
Measure.Latency.prototype = {
    '__proto__': Measure.InletOutlet.prototype
};

// IDEA: Finish A messure Pipe as Hopper and signals end of piped stream and send end on all hopper end (like old done)
// IDEA: Velocity

module.exports = Measure;
