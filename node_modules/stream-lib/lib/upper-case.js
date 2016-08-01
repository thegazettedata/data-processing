/*jslint node:true*/

'use strict';
var Transform = require('stream').Transform;

/**
 * Transform a stream to upper case text
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib
 * @constructor
 * @augments {stream.Transform}
 */
var UpperCase = function HexEncoder() {
    Transform.apply(this, arguments);
};
/*jslint unparam: true*/
UpperCase.prototype = {
    '__proto__': Transform.prototype,
    '_transform': function (chunk, encoding, next) {
        this.push(chunk.toString().toUpperCase());
        next();
    }
};
/*jslint unparam: false*/

module.exports = UpperCase;
