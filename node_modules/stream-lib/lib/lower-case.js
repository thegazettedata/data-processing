/*jslint node:true*/

'use strict';

var Transform = require('stream').Transform;

/**
 * Transform a stream to lower case text
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Transform}
 */
var LowerCase = function HexEncoder() {
    Transform.apply(this, arguments);
};
/*jslint unparam: true*/
LowerCase.prototype = {
    '__proto__': Transform.prototype,
    '_transform': function (chunk, encoding, next) {
        this.push(chunk.toString().toLowerCase());
        next();
    }
};
/*jslint unparam: false*/

module.exports = LowerCase;
