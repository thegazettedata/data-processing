/*jslint node:true*/

'use strict';

var Writable = require('stream').Writable;

/**
 * Not ending consumer without really processing the streamed data.
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @param {boolean} [msg=true] - Should display warning message?
 * @memberOf streamLib
 * @constructor
 */
var Null = function (msg) {

    if (msg !== false) {
        console.warn(new Error('You should know what you want to do, when you create a null stream'));
    }

    Writable.call(this, {objectMode: true});
};

/*jslint unparam: true*/
Null.prototype = {
    '__proto__': Writable.prototype,

    '_write': function (chunk, enc, next) {
        return next();
    },

    '_end': function () {
        Writable.prototype.end.apply(this, arguments);
    },
    end: function () {
        return true;
    }
};
/*jslint unparam: false*/

module.exports = Null;
