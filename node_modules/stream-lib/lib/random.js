/*jslint node:true*/

'use strict';

var Readable = require('stream').Readable;

var numbers = '1234567890';
var alphabet = 'abcdefghijklmnopqrstuvwxyz';
var marks = '^°!"§$%&/()=?`´+\'\\|<>#-_.:,;';

/**
 * Create a stream of random values from dictionary
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib
 * @augments {stream.Readable}
 */
var Random = function Random(opts) {
    Readable.apply(this, arguments);

    if (opts && opts.objectMode) {
        this.objectMode = true;
    }

    this.dictionary = ['1', '0'];
};
Random.prototype = {
    '__proto__': Readable.prototype,

    '_read': function (bytes) {
        var randomValue,
            i,
            buffer;

        if (this.countdown === 0) {
            return this.push(null);
        }

        if (this.objectMode) {
            randomValue = Math.floor(Math.random() * this.dictionary.length);
            this.push(this.dictionary.slice(randomValue, randomValue + 1)[0]);
            this.countdown -= 1;
        } else {
            if (this.countdown >= 0 && this.countdown < bytes) {
                buffer = new Buffer(this.countdown);
            } else {
                buffer = new Buffer(bytes);
            }
            this.countdown -= buffer.length;
            for (i = 0; i < buffer.length; i += 1) {
                randomValue = Math.floor(Math.random() * this.dictionary.length);
                randomValue = this.dictionary.slice(randomValue, randomValue + 1)[0];
                if (typeof randomValue === 'string') {
                    //noinspection JSCheckFunctionSignatures,JSCheckFunctionSignatures
                    buffer[i] = randomValue.charCodeAt();
                } else if (typeof randomValue === 'number') {
                    buffer[i] = randomValue;
                }
            }
            this.push(buffer);
        }
        if (this.countdown === 0) {
            this.push(null);
        }
    },

    /**
     * Add values to the random dictionary
     * @param {*} val - Value to add
     * @returns {Random}
     */
    add: function (val) {
        this.dictionary.push(val);
        return this;
    },
    /**
     * Remove a value from random dictionary
     * @param val
     * @returns {Random}
     */
    remove: function (val) {
        var index = this.dictionary.indexOf(val);

        if (index !== -1) {
            this.dictionary.splice(index, 1);
        }
        return this;
    },

    /**
     * Countdowns of bytes till end (negative values are never ending)
     * @type {number}
     */
    countdown: -1,
    /**
     * Dictionary for random data. You should add and remove with the methods
     * @type {Array}
     */
    dictionary: ['1', '0'],
    objectMode: false
};

/**
 * A stream sending random numbers
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.Numbers = function RandomNumbersStream() {
    Random.apply(this, arguments);

    this.dictionary = numbers.split('');
};
Random.Numbers.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random lower case letters
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.LowerCase = function RandomLowerCaseStream() {
    Random.apply(this, arguments);

    this.dictionary = alphabet.split('');
};
Random.LowerCase.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random upper case letters
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.UpperCase = function RandomUpperCaseStream() {
    Random.apply(this, arguments);

    this.dictionary = alphabet.toUpperCase().split('');
};
Random.UpperCase.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random upper and lower case letters
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.UpperAndLowerCase = function RandomUpperAndLowerCaseStream() {
    Random.apply(this, arguments);

    this.dictionary = (alphabet + (alphabet.toUpperCase())).split('');
};
Random.UpperAndLowerCase.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random letters and numbers
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.Alphanumeric = function RandomAlphanumericStream() {
    Random.apply(this, arguments);

    this.dictionary = (alphabet + numbers + (alphabet.toUpperCase())).split('');
};
Random.Alphanumeric.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random letters, numbers and marks
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.Char = function RandomCharStream() {
    Random.apply(this, arguments);

    this.dictionary = (marks + alphabet + numbers + (alphabet.toUpperCase())).split('');
};
Random.Char.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random marks
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.Marks = function RandomMarksStream() {
    Random.apply(this, arguments);

    this.dictionary = marks.split('');
};
Random.Marks.prototype = {
    '__proto__': Random.prototype
};

/**
 * A stream sending random Hexadecimal
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @constructor
 * @memberOf streamLib.Random
 * @augments {streamLib.Random}
 */
Random.Hex = function RandomHexStream() {
    Random.apply(this, arguments);
    var str = 'ABCDEF0123456789';
    this.dictionary = str.split('');
};
Random.Hex.prototype = {
    '__proto__': Random.prototype
};

module.exports = Random;
