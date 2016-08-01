# node-stream-lib
A library with stream utilities for node.js

## How to install

```bash
npm install -s stream-lib
```

## How to use

### In general
```js
var streamLib = require('stream-lib');

// your streamlib module like:
// new streamLib.Random.Alphanumeric();
```

*Please take also a look into the [JSDoc](streamlib.atd-schubert.com/jsdoc/index.html)*

### Buffer

Buffers a stream in memory with a duplex stream. You are able to save the content in memory if the destination works
slower then the source. You are able to close the destination earlier.

You can also use it in object mode, when you set the first paramerter to true;

```js
var streamLib = require('stream-lib');

// You need some source and destination streams
var fs = require('fs');

var sourceStream = fs.createReadStream('/path/to/your/source.file');
var destinationStream = fs.createWriteStream('/path/to/your/destination.file');

// You need the buffer stream
var objectMode = false;                    // This is optional
var bufferStream = new streamLib.Buffer({objectMode: objectMode});

sourceStream.pipe(decoderStream)
    .pipe(destinationStream);

```

### Concat

Concat multiple streams in given order.

```js
var streamLib = require('stream-lib');

// You need some source and destination streams
var fs = require('fs');

var firstStream = fs.createReadStream('/path/to/your/first.file');
var secondStream = fs.createReadStream('/path/to/your/second.file');
var thirdStream = fs.createReadStream('/path/to/your/third.file');
var destinationStream = fs.createWriteStream('/path/to/your/destination.file');

// You need the concat stream
var concatStream = new streamLib.Concat();

firstStream
    .pipe(concatStream);
secondStream
    .pipe(concatStream);
thirdStream
    .pipe(concatStream);

concatStream.pipe(destinationStream);

```

### Delay

Delay the flow of a stream.

*There are a lot of other pipes. Please take a look in API-doc*

```js
var streamLib = require('stream-lib');

// You need some source and destination streams
var fs = require('fs');

var sourceStream = fs.createReadStream('/path/to/your/source.file');
var destinationStream = fs.createWriteStream('/path/to/your/destination.file');

// You need the buffer stream
var delay = 500;                                  // Delay in milli-seconds (Zero makes it just asynchronous)
var objectMode = false;                           // This is optional
var delayStream = new streamLib.Pipe.Delay({objectMode: objectMode});

sourceStream.pipe(delayStream)
    .pipe(destinationStream);

```

### Event

An event stream works like a normal event emitter but works with streams.

You are also able to augment an existing event emitter with the eventStream.

```js
var streamLib = require('stream-lib');

// Create an event stream

var eventStream = new streamLib.Event();


// For sending and getting Events
eventStream.receive('test', function (data) {
    console.log('Test received:', data);
});

eventStream.send('test', 'Hello!');


var EventEmitter = require('events').EventEmitter;

// anotherEventStream

var anotherEventStream = new streamLib.Event();

anotherEventStream.receive('test', function () {});

eventStr.pipe(anotherEventStream);

```

### Unit

Create a unit of different pipes.

```js
var streamLib = require('stream-lib');

// Create an unit

var unit = new streamLib.Unit();

// Create streams for the unit

var hexDecoder = new streamLib.HexEncoder();
var toUpperCaseStream = new streamLib.UpperCase();

// Combine to an unit

HexEncoder
    .pipe(toUpperCaseStream);

unit.setWritableStream(HexEncoder);
unit.setReadableStream(toUpperCaseStream);

// Now the unit create an upper case hex string

```

### Sequence

Streams a never ending recorded sequence.

```js
var streamLib = require('stream-lib');

// Create an sequence

var sequence = new streamLib.Sequence();

sequence.write('1');
sequence.write('2');
sequence.write('4');
sequence.write('8');
sequence.write('16');
sequence.end();

sequence.on('data', function (chunk) {
    console.log(chunk.toString());
});

// Outputs 1 2 4 8 16 1 2 4 8 16 1 2 4 8 16 1 2 4 8 16 1 2 4 8 16 1 2 4 8 16 1 2 4 8 16 1 2 4 8 16 ...

```
### Measure

Makes measures on a stream

```js
var streamLib = require('stream-lib');

// Create a measure

var measure = new streamLib.Measure.Capacity();

// Create some asynchronous pipes

var firstPipe = new streamLib.Pipe.Async();
var secondPipe = new streamLib.Pipe.Async();
var thirdPipe = new streamLib.Pipe.Async();

measure.measureInlet
    .pipe(firstPipe)
    .pipe(secondPipe)
    .pipe(thirdPipe)
    .pipe(measure.measureOutlet);

measure.measureInlet.write('1');
measure.measureInlet.write('2');
measure.measureInlet.write('3');
measure.measureInlet.write('4');
measure.measureInlet.write('5');
measure.measureInlet.end();

measure.on('data', function (chunk) {
    console.log(chunk.capacity);       // Now you got the measured capacity of the streams
});

```
