
var assert = require('better-assert');
var through = require('through');
var from = require('from');
var reduce = require('stream-reduce');
var queue = require('../');
var debug = require('debug')('concurrent-map-stream:test');

var consume = function(){
  return reduce(function(items, val){
    debug("consuming %s", val);
    items.push(val);
    return items;
  }, []);
};

function worker(n, done) {
  setTimeout(function(){ done(null, n); }, n);
}

describe('concurrent-map-stream', function(){
  it('sync works', function(done){

    from([80, 50, 5, 2, 3, 25, 60, 15])
    .pipe(queue(worker, 5))
    .pipe(consume())
    .pipe(through(function(items){
      assert(items[0] === 80);
      assert(items[1] === 50);
      assert(items[2] === 5);
      assert(items[3] === 2);
      assert(items[4] === 3);
      assert(items[5] === 25);
      assert(items[6] === 60);
      assert(items[7] === 15);
      done();
    }));

  });

  it('async works', function(done) {
    var stream = through();
    stream.pause();

    stream
    .pipe(queue(worker, 5))
    .pipe(consume())
    .pipe(through(function(items){
      assert(items[0] === 80);
      assert(items[1] === 20);
      assert(items[2] === 2);
      assert(items[3] === 60);
      assert(items[4] === 79);
      assert(items[5] === 21);
      done();
    }));

    stream.write(80);
    stream.write(20);
    stream.write(2);
    stream.write(60);
    stream.write(79);

    setTimeout(function(){
      stream.queue(21);
      stream.resume();
    }, 100);

  });
});
