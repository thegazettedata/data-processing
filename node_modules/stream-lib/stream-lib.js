/*jslint node:true*/

'use strict';


/**
 * Root module for streamLibs.
 *
 * @author Arne Schubert <atd.schubert@gmail.com>
 * @module streamLib
 */

/**
 * Associative array of lib classes.
 * @type {{}}
 * @property {streamLib.BufferStream} Buffer
 * @property {streamLib.Concat} Concat
 * @property {streamLib.EventStream} Event
 * @property {streamLib.hex} hex
 * @property {streamLib.LowerCase} LowerCase
 * @property {streamLib.Measure} Measure
 * @property {streamLib.Null} Null
 * @property {streamLib.Pipe} Pipe
 * @property {streamLib.Random} Random
 * @property {streamLib.Sequencer} Sequencer
 * @property {streamLib.Spawn} Spawn
 * @property {streamLib.Unit} Unit
 * @property {streamLib.UpperCase} UpperCase
 */
/*
 * @property {streamLib.Beat} Beat private at this time
 * @property {streamLib.Sluice} Sluice private at this time
 */
var streamLib = {
    Beat: require('./lib/beat'),
    Buffer: require('./lib/buffer'),
    Concat: require('./lib/concat'),
    Event: require('./lib/event'),
    hex: require('./lib/hex'),
    LowerCase: require('./lib/lower-case'),
    Measure: require('./lib/measure'),
    Null: require('./lib/null'),
    Pipe: require('./lib/pipe'),
    Random: require('./lib/random'),
    Sequencer: require('./lib/sequencer'),
    Spawn: require('./lib/spawn'),
    Sluice: require('./lib/sluice'),
    Unit: require('./lib/unit'),
    UpperCase: require('./lib/upper-case')
};

module.exports = streamLib;

/**
 * Stream library from node.js
 * @private
 * @alias stream
 * @name stream
 * @type {{}}
 * @property {stream.Readable} Readable - Readable stream constructor from node.js
 * @property {stream.Writable} Writable - Writable stream constructor from node.js
 * @property {stream.Duplex} Duplex - Readable and Writable stream constructor from node.js
 * @property {stream.Transform} Transform - Transform-Duplex stream constructor from node.js
 *
 */
