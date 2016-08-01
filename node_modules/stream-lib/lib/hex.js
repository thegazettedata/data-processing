/*jslint node:true*/

'use strict';

var Transform = require('stream').Transform;


/**
 * Collection of hexadecimal streams
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @type {{}}
 * @alias streamLib.hex
 * @memberOf streamLib
 * @property {hex.Encoder} Encoder
 * @property {hex.Decoder} Decoder
 */
var hex = {};

/**
 * Encode a stream to a hex stream
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @memberOf streamLib.hex
 * @constructor
 * @augments {stream.Transform}
 */
hex.Encoder = function HexEncoder() {
    Transform.apply(this, arguments);
};
/*jslint unparam: true*/
hex.Encoder.prototype = {
    '__proto__': Transform.prototype,
    '_transform': function (chunk, encoding, next) {
        var result = '',
            i,
            str;

        for (i = 0; i < chunk.length; i += 1) {
            str = chunk[i].toString(16);
            result += (str.length === 1 ? '0' + str : str);
        }
        this.push(result);
        next();
    }
};
/*jslint unparam: false*/

/**
 * Decode a stream from a hex stream
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.hex
 * @augments {stream.Transform}
 */
hex.Decoder = function HexDecoder() {
    Transform.apply(this, arguments);
    this.rest = '';
};
/*jslint unparam: true*/
hex.Decoder.prototype = {
    '__proto__': Transform.prototype,
    '_transform': function (chunk, encoding, next) {
        var hex,
            i,
            result;

        hex = this.rest + chunk.toString();

        if (hex.length % 2) {
            this.rest = hex.substr(-1);
            hex = hex.substring(0, hex.length - 1);
        }

        result = new Buffer(hex.length / 2);

        for (i = 0; i < result.length; i += 1) {
            result[i] = parseInt(hex.substr(i * 2, 2), 16);
        }
        this.push(result);
        next();
    },
    rest: ''
};
/*jslint unparam: false*/

module.exports = hex;
