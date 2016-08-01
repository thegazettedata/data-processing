/*jslint node:true*/

'use strict';

var Pipe = require('./pipe').ObjectMode;

/**
 * Events piping through streams
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @param {String} name - name of the event
 * @param {*} data - On event binded data
 * @param {EventStream} origin - EventStream that sends the data
 * @param {number} [priority=0] - Priority of this message
 * @constructor
 * @memberOf streamLib
 * @augments streamLib.Pipe
 */
var StreamEvent = function (name, data, origin, priority) {
    this.timestamp = Date.now();
    this.name = name;
    this.data = data;
    this.origin = origin;
    this.priority = priority || 1;
};
StreamEvent.prototype = {
    getName: function () {
        return this.name;
    },
    getOrigin: function () {
        return this.origin;
    },
    getData: function () {
        return this.data;
    },
    getPriority: function () {
        return this.priority;
    }
};

/**
 * Create an event stream that works like normal event emitters but on streams
 * @constructor
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib
 * @augments streamLib.Pipe.ObjectMode
 */
var EventStream = function EventStream() {

    Pipe.apply(this, arguments);
    this.eventStreamListeners = [];
};
/*jslint unparam: true*/
EventStream.prototype = {
    '__proto__': Pipe.prototype,

    '_transform': function (chunk, encoding, next) {
        var i;

        if (chunk.origin === this) {
            /**
             * Circuit event, when a sended event come back into writeable stream.
             * @event streamLinb.EventStream#circuit
             * @type {Buffer|*}
             */
            this.emit('circuit', chunk);
            return next();
        }

        for (i = 0; i < this.eventStreamListeners.length; i += 1) {
            this.eventStreamListeners[i](chunk);
        }

        /*jslint nomen: true*/
        Pipe.prototype._transform.apply(this, arguments);
        /*jslint nomen: false*/
    },

    /**
     * Send an event over a stream
     * @param {string} name - Event name
     * @param {*} data - Data to bind on event
     * @returns {EventStream}
     */
    send: function (name, data) {
        /**
         * @alias eventStream~event
         * @type {StreamEvent}
         */
        var event = new StreamEvent(name, data, this);
        this.push(event);
        return this;
    },
    /**
     * Receive an event from a stream
     * @param {string|RegExp|{test:function}} name - Name of the events that should be listened
     * @param {function} fn - Function to execute when receiving event
     * @returns {EventStream.handle}
     */
    receive: function streamOn(name, fn) {
        var str,
            handle;
        if (typeof name === 'string') {
            str = name;
            name = {
                test: function (val) {
                    return val === str;
                }
            };
        }
        /**
         * @callback {EventStream.handle}
         * @param chunk
         * @type {function}
         */
        handle = function (chunk) {
            if (name.test(chunk.name)) {
                fn(chunk.data);
            }
        };
        this.eventStreamListeners.push(handle);
        return handle;
    },
    /**
     * Receive an event once from a stram
     * @param {string|RegExp|{test:function}} name - Name of the events that should be listened
     * @param {function} fn - Function to execute when receiving event
     * @returns {EventStream.handle}
     */
    receiveOnce: function streamOn(name, fn) {
        var str,
            self = this,
            handle;
        if (typeof name === 'string') {
            str = name;
            name = {
                test: function (val) {
                    return val === str;
                }
            };
        }
        handle = function (chunk) {
            if (name.test(chunk.name)) {
                self.removeReceiver(handle);
                fn(chunk.data);
            }
        };
        this.eventStreamListeners.push(handle);
        return handle;
    },
    /**
     * Remove a receiver
     * @param {EventStream.handle} handle - Handle from receiver creation
     * @returns {boolean}
     */
    removeReceiver: function (handle) {
        var pos = this.eventStreamListeners.indexOf(handle);
        if (pos === -1) {
            return false;
        }
        this.eventStreamListeners.splice(this.eventStreamListeners.indexOf(handle), 1);
        return true;
    },

    /**
     * Send emitted events from an event emitter on event stream with prefix
     * @param {events.EventEmitter} emitter - Event Emitter
     * @param {string} [eventPrefix=""] - Prefix events with this prefix on event stream
     * @returns {EventStream}
     */
    augmentEmitter: function (emitter, eventPrefix) {
        var self = this,
            oldEmit = emitter.emit;

        eventPrefix = eventPrefix || '';

        emitter.emit = function (name, data) {
            oldEmit.apply(emitter, arguments);
            self.send(eventPrefix + name, data);
        };
        return this;
    },
    /**
     * Emits received events from event stream on a normal event emitter with prefix
     * @param {events.EventEmitter} listener - Event Emitter
     * @param {string} [eventPrefix=""] - Prefix streamed events with this prefix on event emitter
     * @returns {EventStream}
     */
    augmentListener: function (listener, eventPrefix) {
        var lastName;

        eventPrefix = eventPrefix || '';

        this.receive({
            test: function (val) {
                lastName = val;
                return true;
            }
        }, function (data) {
            listener.emit(eventPrefix + lastName, data);
        });
        return this;
    },

    /**
     * Collection of registered listeners for event stream
     * @type {function[]}
     */
    eventStreamListeners: []
};
/*jslint unparam: false*/

/**
 * Filter events
 * @param {string|RegExp|{test: function}} filter - Event name filter
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.EventStream
 * @augments {streamLib.EventStream}
 */
EventStream.Filter = function EventFilterStream(filter) {
    var str;

    EventStream.apply(this, arguments);

    if (filter) {
        if (typeof filter === 'string') {
            str = filter;
            filter = {
                test: function (val) {
                    return val === str;
                }
            };
        }
        this.filter = filter;
    }
};
EventStream.Filter.prototype = {
    '__proto__': EventStream.prototype,
    '_transform': function (chunk, encoding, next) {
        /*jslint nomen: true*/
        if (this.filter.test(chunk.name)) {
            return EventStream.prototype._transform.call(this, chunk, encoding, next);
        }
        /*jslint nomen: false*/
        return next();
    },

    /**
     * Filter function
     * @type {RegExp|{test: function}}
     */
    filter: {
        test: function () {
            return true;
        }
    }
};
/**
 * Pipe an event with a prefix
 * @param {string} prefix - Prefix that should be used
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.EventStream
 * @augments {streamLib.EventStream}
 */
EventStream.Prefix = function EventPrefixStream(prefix) {
    EventStream.apply(this, arguments);

    this.prefix = prefix || this.prototype.prefix;
};
/*jslint nomen: true*/
EventStream.Prefix.prototype = {
    '__proto__': EventStream.prototype,
    '_transform': function (chunk, encoding, next) {
        var tmp = {},
            hash;

        for (hash in chunk) {
            if (chunk.hasOwnProperty(hash)) {
                tmp[hash] = chunk[hash];
            }
        }
        tmp.name = this.prefix + tmp.name;

        return EventStream.prototype._transform.call(this, tmp, encoding, next);
    },

    prefix: ''
};
/*jslint nomen: false*/

/**
 * Pipe an event without prefix
 * @param {string} prefix - Prefix that should be used
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.EventStream
 * @augments {streamLib.EventStream}
 */
EventStream.Unprefix = function EventUnprefixStream(prefix) {
    EventStream.apply(this, arguments);

    this.prefix = prefix || this.prototype.prefix;
};
/*jslint nomen: true*/
EventStream.Unprefix.prototype = {
    '__proto__': EventStream.prototype,
    '_transform': function (chunk, encoding, next) {
        var tmp = {},
            hash;
        if (chunk.name.indexOf(this.prefix) !== 0) {
            return next();
        }

        for (hash in chunk) {
            if (chunk.hasOwnProperty(hash)) {
                tmp[hash] = chunk[hash];
            }
        }
        tmp.name = tmp.name.substr(this.prefix.length);

        return EventStream.prototype._transform.call(this, tmp, encoding, next);
    },

    prefix: ''
};
/*jslint nomen: false*/

/**
 * Pipe an event with a postfix
 * @param {string} postfix - Prefix that should be used
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.EventStream
 * @augments {streamLib.EventStream}
 */
EventStream.Postfix = function EventPostfixStream(postfix) {
    EventStream.apply(this, arguments);

    this.postfix = postfix || this.prototype.postfix;
};
/*jslint nomen: true*/
EventStream.Postfix.prototype = {
    '__proto__': EventStream.prototype,
    '_transform': function (chunk, encoding, next) {
        var tmp = {},
            hash;

        for (hash in chunk) {
            if (chunk.hasOwnProperty(hash)) {
                tmp[hash] = chunk[hash];
            }
        }
        tmp.name = tmp.name + this.postfix;

        return EventStream.prototype._transform.call(this, tmp, encoding, next);
    },

    postfix: ''
};
/*jslint nomen: false*/


/**
 * Pipe an event without postfix
 * @param {string} postfix - Prefix that should be used
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.EventStream
 * @augments {streamLib.EventStream}
 */
EventStream.Unpostfix = function EventUnpostfixStream(postfix) {
    EventStream.apply(this, arguments);

    this.postfix = postfix || this.prototype.postfix;
};
/*jslint nomen: true*/
EventStream.Unpostfix.prototype = {
    '__proto__': EventStream.prototype,
    '_transform': function (chunk, encoding, next) {
        var tmp = {},
            hash,
            index = chunk.name.indexOf(this.postfix);

        if (index < 1 || index + this.postfix.length !== chunk.name.length) {
            return next();
        }

        for (hash in chunk) {
            if (chunk.hasOwnProperty(hash)) {
                tmp[hash] = chunk[hash];
            }
        }
        tmp.name = tmp.name.substring(0, tmp.name.length - this.postfix.length);

        return EventStream.prototype._transform.call(this, tmp, encoding, next);
    },

    postfix: ''
};
/*jslint nomen: false*/

// IDEA: PriorityBuffer

module.exports = EventStream;
