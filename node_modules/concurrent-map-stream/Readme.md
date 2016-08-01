
# concurrent-map-stream

  Concurrently transform a stream in FIFO order

  [![Build Status](https://travis-ci.org/jb55/concurrent-map-stream.png)](https://travis-ci.org/jb55/concurrent-map-stream)

## Installation

  Install with npm

    $ npm install concurrent-map-stream

## API

### queue(worker, concurrency)

returns a `through` stream

## Example

```js
var queue = require('concurrent-map-stream');
var stream = require('through')();

function worker(n, done) {
  setTimeout(function(){ done(null, n); }, n);
}

stream
.pipe(queue(worker, 5))
.pipe(through(function(n){
  console.log(n);
}));

[80, 50, 5, 100, 30, 20, 2].forEach(function(n){
  stream.write(n);
});

// results in a stream numbers in the proper order
// will only take at most 100ms to execute
```

## License

  The MIT License (MIT)

  Copyright (c) 2014 William Casarin

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
