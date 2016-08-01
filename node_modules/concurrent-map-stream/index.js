

var SimpleQueue = require('SimpleQueue');
var duplex = require('duplex');
var debug = require('debug')('concurrent-map-stream');

module.exports = function(worker, concurrency) {
  var queue = new SimpleQueue(worker, processed, end, concurrency);
  var stream = duplex();

  stream.on('_data', function(data) {
    debug('_data %s', data);
    queue.push(data);
  });

  function end() {
    stream._end();
  }

  function processed(err, result) {
    if (err != null) stream.emit('error', err);
    stream._data(result);
  }

  return stream;
};
