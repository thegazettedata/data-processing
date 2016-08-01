/*jslint node: true*/

/*globals describe, it, after, before, afterEach, beforeEach*/

'use strict';

var streamLib = require('../');

describe('streamLib', function () {

    var BIGAMOUNT   = 100000,
        SMALLAMOUNT = 1000;

    describe('Random', function () {
        it('should get a preset amount of random data', function (done) {
            var randomStream = new streamLib.Random(),
                result = '';

            randomStream.countdown = BIGAMOUNT;

            randomStream.on('data', function (chunk) {
                result += chunk.toString();
            });
            randomStream.on('end', function () {
                if (result.length === BIGAMOUNT) {
                    return done();
                }
                return done(new Error('Wrong string length'));
            });

        });

        it('should get zeros and ones by default', function (done) {
            var randomStream = new streamLib.Random(),
                zero,
                one;

            randomStream.on('readable', function () {
                var val;

                if (zero && one) {
                    return;
                }

                val = randomStream.read(1).toString();
                if (val === '0') {
                    zero = true;
                } else if (val === '1') {
                    one = true;
                } else {
                    return done(new Error('Got a non zero or one result!'));
                }

                if (zero && one) {
                    return done();
                }
                randomStream.read(0);

            });
        });
        it('should get another dictionary if you want to', function (done) {
            var randomStream = new streamLib.Random(),
                a,
                b,
                c;

            randomStream.dictionary = ['a', 'b', 'c'];

            randomStream.on('readable', function () {
                var val;
                if (a && b && c) {
                    return;
                }

                val = randomStream.read(1).toString();
                if (val === 'a') {
                    a = true;
                } else if (val === 'b') {
                    b = true;
                } else if (val === 'c') {
                    c = true;
                } else {
                    return done(new Error('Got a non zero or one result!'));
                }

                if (a && b && c) {
                    return done();
                }
                randomStream.read(0);

            });
        });
        describe('object mode', function () {
            it('should use random elements as objects', function (done) {
                var testObj = {},
                    randomStream = new streamLib.Random({objectMode: true}),
                    found;

                randomStream.dictionary = [{type: 'first'}, {type: 'second'}, testObj];
                randomStream.on('readable', function () {
                    if (found) {
                        return;
                    }
                    var elems = randomStream.read();

                    if (elems === testObj) {
                        found = true;
                        return done();
                    }
                    randomStream.read(0);
                });
            });
        });
    });

    describe('Null', function () {
        it('should pipe a stream to the end', function (done) {
            var randomStream = new streamLib.Random.Alphanumeric(),
                nullStream = new streamLib.Null(false);

            randomStream.countdown = BIGAMOUNT;

            randomStream.on('end', done);
            randomStream.pipe(nullStream);

        });
        it('should always be writable', function (done) {
            var randomStream = new streamLib.Random.Alphanumeric(),
                nullStream = new streamLib.Null(false);

            randomStream.countdown = SMALLAMOUNT;

            randomStream.on('end', function () {
                setTimeout(function () {
                    nullStream.write('It still works');

                    return done();
                }, 1);
            });
            randomStream.pipe(nullStream);
        });
        it('should be able to end a input stream directly', function (done) {
            var pipeStream = new streamLib.Pipe(),
                nullStream = new streamLib.Null(false);

            pipeStream.on('end', function () {
                setTimeout(function () {
                    nullStream.write('It still works');

                    return done();
                }, 1);
            });
            pipeStream.pipe(nullStream);

            pipeStream.end();
        });
    });

    describe('Pipe', function () {
        it('should pipe through SMALLAMOUT of pipes', function (done) {
            var firstPipe = new streamLib.Pipe(),
                lastPipe = firstPipe,
                i,
                testStr = 'just a test';

            for (i = 0; i < SMALLAMOUNT; i += 1) {
                lastPipe = (new streamLib.Pipe()).pipe(lastPipe);
                lastPipe.setMaxListeners(SMALLAMOUNT);
            }

            lastPipe.on('data', function (chunk) {
                if (chunk.toString() === testStr) {
                    return done();
                }
                return done(new Error('Wrong chunk'));
            });

            firstPipe.write(testStr);

        });

        describe('Delay', function () {
            it('should delay a stream', function (done) {
                var delayStream = new streamLib.Pipe.Delay(),
                    randomStream = new streamLib.Random.Alphanumeric(),
                    randomChunks = [],
                    delayChunks = [],
                    delay;

                delayStream.delay = 50;
                randomStream.countdown = SMALLAMOUNT;

                randomStream.pipe(delayStream);

                randomStream.on('data', function (chunk) {
                    randomChunks.push(chunk.toString());
                });
                delayStream.on('data', function (chunk) {
                    delayChunks.push(chunk.toString());
                });

                randomStream.on('end', function () {
                    delay = Date.now();
                    randomChunks = randomChunks.join('');
                });

                delayStream.on('end', function () {
                    delay = Date.now() - delay;
                    delayChunks = delayChunks.join('');
                    if (delayChunks === randomChunks && delay >= 50) {
                        return done();
                    }
                    return done(new Error('Wrong content or delay time'));
                });
            });
        });
        describe('Async', function () {
            it('should make a stream async', function (done) {
                var asyncStream = new streamLib.Pipe.Async(),
                    randomStream = new streamLib.Random.Alphanumeric(),
                    randomChunks = [],
                    delayChunks = [],
                    delay;

                randomStream.countdown = SMALLAMOUNT;

                randomStream.pipe(asyncStream);

                randomStream.on('data', function (chunk) {
                    randomChunks.push(chunk.toString());
                });
                asyncStream.on('data', function (chunk) {
                    delayChunks.push(chunk.toString());
                });

                randomStream.on('end', function () {
                    delay = Date.now();
                    randomChunks = randomChunks.join('');
                });

                asyncStream.on('end', function () {
                    delay = Date.now() - delay;
                    delayChunks = delayChunks.join('');
                    if (delayChunks === randomChunks) {
                        return done();
                    }
                    return done(new Error('Wrong content or delay time'));
                });
            });
        });

        describe('Once', function () {
            var oncePipe = new streamLib.Pipe.Once(),
                asyncPipe = new streamLib.Pipe.Async(),
                senderPipe = new streamLib.Pipe(),
                receiverPipe = new streamLib.Pipe();

            senderPipe.pipe(oncePipe)
                .pipe(asyncPipe)
                .pipe(receiverPipe)
                .pipe(senderPipe);

            it('should new receive emitted package once', function (done) {
                var testObj = new Buffer('just a test');

                receiverPipe.on('data', function (chunk) {
                    if (chunk === testObj) {
                        return done();
                    }
                });

                senderPipe.write(testObj);
            });

        });

        describe('Chain', function () {
            it('should pipe data', function (done) {
                var chainPipe = new streamLib.Pipe.Chain(),
                    pipedStr = '',
                    testStr = 'just a test';

                chainPipe.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });
                chainPipe.on('end', function () {
                    if (testStr === pipedStr) {
                        return done();
                    }
                    return done(new Error('Wrong content'));
                });

                chainPipe.write(testStr);
                chainPipe.end();
            });
            it('should insert before another chain', function (done) {
                var firstChain = new streamLib.Pipe.Chain(),
                    secondChain = new streamLib.Pipe.Chain(),
                    testChain = new streamLib.Pipe.Chain(),
                    pipedStr = '',
                    testStr = 'just a test',
                    firstEnded,
                    secondEnded;

                firstChain
                    .chainBefore(secondChain);

                testChain
                    .chainAfter(firstChain);

                testChain.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });
                testChain.on('end', function () {
                    if (firstEnded && !secondEnded && pipedStr === testStr) {
                        return done();
                    }
                    return done(new Error('Not chained correctly or wrong content received'));
                });

                /*jslint debug: true*/
                secondChain.on('data', function () {});
                /*jslint debug: false*/
                secondChain.on('end', function () {
                    secondEnded = true;
                });
                firstChain.on('end', function () {
                    firstEnded = true;
                });

                firstChain.write(testStr);
                firstChain.end();
            });
            it('should insert before another chain', function (done) {
                var firstChain = new streamLib.Pipe.Chain(),
                    secondChain = new streamLib.Pipe.Chain(),
                    testChain = new streamLib.Pipe.Chain(),
                    pipedStr = '',
                    testStr = 'just a test',
                    firstEnded,
                    secondEnded;

                firstChain
                    .chainBefore(secondChain);

                testChain
                    .chainBefore(secondChain);

                testChain.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });
                testChain.on('end', function () {
                    if (firstEnded && !secondEnded && pipedStr === testStr) {
                        return done();
                    }
                    return done(new Error('Not chained correctly or wrong content received'));
                });

                /*jslint debug: true*/
                secondChain.on('data', function () {});
                /*jslint debug: false*/
                secondChain.on('end', function () {
                    secondEnded = true;
                });
                firstChain.on('end', function () {
                    firstEnded = true;
                });

                firstChain.write(testStr);
                firstChain.end();
            });
        });

        describe('Tap', function () {
            it('should pipe data in normal state', function (done) {
                var tapPipe = new streamLib.Pipe.Tap(),
                    testStr = 'just a test',
                    pipedStr = '';

                tapPipe.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });

                tapPipe.on('end', function () {
                    if (pipedStr === testStr) {
                        return done();
                    }
                    return done(new Error('Wrong content'));
                });

                tapPipe.write(testStr);
                tapPipe.end();
            });
            it('should not pipe data but consume them in locked state and interpret end', function (done) {
                var tapPipe = new streamLib.Pipe.Tap(),
                    pipeStream = new streamLib.Pipe(),
                    testStr = 'just a test',
                    pipedStr = '';

                tapPipe.lock();

                tapPipe.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });

                tapPipe.on('end', function () {
                    if (pipedStr === '') {
                        return done();
                    }
                    return done(new Error('Send content through a locked tap pipe'));
                });

                pipeStream
                    .pipe(tapPipe);

                pipeStream.write(testStr);
                pipeStream.end();
            });
            it('should be able to lock and unlock tap', function (done) {
                var tapPipe = new streamLib.Pipe.Tap(),
                    pipeStream = new streamLib.Pipe(),
                    testStr = 'just a test',
                    pipedChunks = 0,
                    tapedChunks = 0;

                tapPipe.lock();

                pipeStream.on('data', function () {
                    pipedChunks += 1;
                    tapPipe.toggle();
                });

                tapPipe.on('data', function () {
                    tapedChunks += 1;
                });

                tapPipe.on('end', function () {
                    if (pipedChunks > tapedChunks) {
                        return done();
                    }
                    return done(new Error('Does not open and close the tap'));
                });

                pipeStream
                    .pipe(tapPipe);

                pipeStream.write(testStr);
                pipeStream.write(testStr);
                pipeStream.write(testStr);
                pipeStream.write(testStr);
                pipeStream.write(testStr);
                pipeStream.end();
            });
        });

        describe('Gate', function () {
            it('should pipe data in normal state', function (done) {
                var gatePipe = new streamLib.Pipe.Gate(),
                    testStr = 'just a test',
                    pipedStr = '';

                gatePipe.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });

                gatePipe.on('end', function () {
                    if (pipedStr === testStr) {
                        return done();
                    }
                    return done(new Error('Wrong content'));
                });

                gatePipe.write(testStr);
                gatePipe.end();
            });
            it('should collect data in locked state', function (done) {
                var gatePipe = new streamLib.Pipe.Gate(),
                    pipeStream = new streamLib.Pipe(),
                    testStr = 'just a test',
                    pipedStr = '';

                gatePipe.lock();

                gatePipe.on('data', function (chunk) {
                    pipedStr += chunk.toString();
                });

                gatePipe.on('end', function () {
                    if (pipedStr === testStr + testStr + testStr) {
                        return done();
                    }
                    return done(new Error('Wrong content'));
                });

                pipeStream.on('end', function () {
                    if (pipedStr !== '') {
                        return done(new Error('Already piped data'));
                    }
                    gatePipe.unlock();
                });

                pipeStream
                    .pipe(gatePipe);

                pipeStream.write(testStr);
                pipeStream.write(testStr);
                pipeStream.write(testStr);
                pipeStream.end();
            });
        });

        describe('ObjectMode', function () {
            it('should instatiate a Pipe in object mode', function (done) {
                var objectModePipe = new streamLib.Pipe.ObjectMode();
                if (objectModePipe.objectMode === true) {
                    return done();
                }
                return done(new Error('Stream not in object mode'));
            });
            it('should write objects', function () {
                var objectModePipe = new streamLib.Pipe.ObjectMode();

                objectModePipe.write({just: 'a test'});
            });
        });

        describe('Zombie', function () {
            it('should not end after a pumping, ending stream', function (done) {
                var randomStream = new streamLib.Random.Alphanumeric(),
                    zombiePipe = new streamLib.Pipe.Zombie(),
                    testPhrase = 'it still works';

                randomStream.countdown = SMALLAMOUNT;

                randomStream.on('end', function () {
                    setTimeout(function () {
                        zombiePipe.write(testPhrase);
                    }, 1);
                    zombiePipe.on('data', function (data) {
                        if (data.toString() === testPhrase) {
                            return done();
                        }
                    });
                });

                randomStream.pipe(zombiePipe);

            });
        });

        describe('Hopper', function () {
            it('should stop on a single stream', function (done) {
                var hopperStream = new streamLib.Pipe.Hopper(),
                    firstPipe = new streamLib.Pipe(),
                    nullStream = new streamLib.Null(false);

                firstPipe
                    .pipe(hopperStream)
                    .pipe(nullStream);

                hopperStream.on('end', done);

                firstPipe.end();
            });
            it('should stop when both of two pipes ends', function (done) {
                var hopperStream = new streamLib.Pipe.Hopper(),
                    firstPipe = new streamLib.Pipe(),
                    secondPipe = new streamLib.Pipe(),
                    nullStream = new streamLib.Null(false);

                firstPipe
                    .pipe(hopperStream)
                    .pipe(nullStream);

                secondPipe
                    .pipe(hopperStream);
                hopperStream.on('end', done);

                firstPipe.on('end', function () {
                    setTimeout(function () {
                        secondPipe.end();
                    }, 10);
                });

                firstPipe.end();
            });
            it('should stop when unpiping last unfinished pipe', function (done) {
                var hopperStream = new streamLib.Pipe.Hopper(),
                    firstPipe = new streamLib.Pipe(),
                    secondPipe = new streamLib.Pipe(),
                    thirdPipe = new streamLib.Pipe(),
                    nullStream = new streamLib.Null(false),
                    unpiped;

                firstPipe
                    .pipe(hopperStream)
                    .pipe(nullStream);

                secondPipe
                    .pipe(hopperStream);
                thirdPipe
                    .pipe(hopperStream);

                hopperStream.on('end', function () {
                    if (unpiped) {
                        return done();
                    }
                    return done(new Error('Ended before'));
                });

                firstPipe.on('end', function () {
                    setTimeout(function () {
                        secondPipe.end();
                    }, 10);
                });
                secondPipe.on('end', function () {
                    unpiped = true;

                    thirdPipe
                        .unpipe(hopperStream);
                });

                firstPipe.end();
            });
        });
    });

    describe('Measure', function () {

        describe('SinglePipe', function () {
            it('should end measure if pipe has ended', function (done) {
                var measure = new streamLib.Measure.SinglePipe(),
                    nullStream = new streamLib.Null(false);

                measure.on('end', done);

                measure.measurePipe.pipe(nullStream);
                measure.pipe(nullStream);

                measure.measurePipe.end();
            });
        });

        describe('InletOutlet', function () {
            it('should end measure if output pipe has ended', function (done) {
                var measure = new streamLib.Measure.InletOutlet(),
                    nullStream = new streamLib.Null(false);

                measure.on('end', done);


                measure.measureOutlet.pipe(nullStream);
                measure.pipe(nullStream);

                measure.measureOutlet.end();
            });
            it('should end measure with piped data ended', function (done) {
                var measure = new streamLib.Measure.InletOutlet(),
                    firstPipe = new streamLib.Pipe(),
                    secondPipe = new streamLib.Pipe(),
                    nullStream = new streamLib.Null(false);

                measure.on('end', done);


                firstPipe
                    .pipe(measure.measureInlet)
                    .pipe(secondPipe)
                    .pipe(measure.measureOutlet)
                    .pipe(nullStream);

                measure.pipe(nullStream);

                measure.measureOutlet.end();
            });
        });

        describe('Chunk', function () {
            it('should count buffer length and chunks', function (done) {
                var randomStream = new streamLib.Random(),
                    measureChunks = new streamLib.Measure.Chunk(),
                    nullStream = new streamLib.Null(false),
                    countedLength = 0;

                randomStream.countdown = BIGAMOUNT;

                measureChunks.on('data', function (chunk) {
                    countedLength += chunk.length;
                });

                measureChunks.on('end', function () {
                    if (countedLength === BIGAMOUNT) {
                        return done();
                    }
                    return done(new Error('Wrong amount of buffer lengths'));
                });

                randomStream
                    .pipe(measureChunks.measurePipe)
                    .pipe(nullStream);

            });


        });

        describe('Capacity', function () {
            it('should record the capacity of a stream', function (done) {
                var randomStream = new streamLib.Random(),
                    capacityMeasure = new streamLib.Measure.Capacity(),
                    nullStream = new streamLib.Null(false),
                    even = true;


                randomStream.countdown = BIGAMOUNT;

                capacityMeasure.on('data', function (chunk) {
                    if (even) {
                        even = false;
                        if (chunk.capacity.chunks !== 1) {
                            return done(new Error('Even chunk length was not 1'));
                        }
                    } else {
                        even = true;
                        if (chunk.capacity.chunks !== 0) {
                            return done(new Error('Odd chunk length was not 0'));
                        }
                    }

                });

                capacityMeasure.on('end', done);

                randomStream
                    .pipe(capacityMeasure.measureInlet)
                    .pipe(capacityMeasure.measureOutlet)
                    .pipe(nullStream);
            });
            it('should record the capacity of a stream with pipes', function (done) {
                var randomStream = new streamLib.Random(),
                    capacityMeasure = new streamLib.Measure.Capacity(),
                    firstPipeStream = new streamLib.Pipe.Async(),
                    secondPipeStream = new streamLib.Pipe.Async(),
                    nullStream = new streamLib.Null(false),
                    gotTwoChunks;


                randomStream.countdown = BIGAMOUNT;

                capacityMeasure.on('data', function (chunk) {
                    if (chunk.capacity.chunks === 2) {
                        gotTwoChunks = true;
                    }

                });

                capacityMeasure.on('end', function () {
                    if (gotTwoChunks) {
                        return done();
                    }
                    return done(new Error('Never got two chunks!'));
                });

                randomStream
                    .pipe(capacityMeasure.measureInlet)
                    .pipe(firstPipeStream)
                    .pipe(secondPipeStream)
                    .pipe(capacityMeasure.measureOutlet)
                    .pipe(nullStream);

                capacityMeasure.pipe(nullStream);
            });
        });

        describe('Latency', function () {
            it('should record the latency of a stream', function (done) {
                var randomStream = new streamLib.Random(),
                    latencyMeasure = new streamLib.Measure.Latency(),
                    nullStream = new streamLib.Null(false);


                randomStream.countdown = BIGAMOUNT;

                latencyMeasure.on('data', function (chunk) {
                    if (chunk.latency < 0 || chunk.latency > 5) {
                        return done(new Error('Wrong latency'));
                    }

                });

                latencyMeasure.on('end', done);

                randomStream
                    .pipe(latencyMeasure.measureInlet)
                    .pipe(latencyMeasure.measureOutlet)
                    .pipe(nullStream);
            });

            it('should record the latency of a stream with delay', function (done) {
                var randomStream = new streamLib.Random(),
                    latencyMeasure = new streamLib.Measure.Latency(),
                    delayStream = new streamLib.Pipe.Delay(),
                    nullStream = new streamLib.Null(false);


                randomStream.countdown = BIGAMOUNT;
                delayStream.delay = 10;
                latencyMeasure.on('data', function (chunk) {
                    if (chunk.latency < 10) {
                        return done(new Error('Wrong latency'));
                    }

                });

                latencyMeasure.on('end', done);

                randomStream
                    .pipe(latencyMeasure.measureInlet)
                    .pipe(delayStream)
                    .pipe(latencyMeasure.measureOutlet)
                    .pipe(nullStream);
            });
        });
    });

    describe('Buffer', function () {
        it('should buffer a random stream', function (done) {
            var buffer, random, randomData = [], bufferData = [];

            random = new streamLib.Random.Alphanumeric();
            random.countdown = SMALLAMOUNT;

            buffer = new streamLib.Buffer();

            random.pipe(buffer);

            random.on('data', function (chunk) {
                randomData.push(chunk.toString());
            });
            buffer.on('data', function (chunk) {
                bufferData.push(chunk.toString());
            });

            random.on('end', function () {
                randomData = randomData.join('');
                if (typeof bufferData === 'string') {
                    if (randomData === bufferData) {
                        return done();
                    }
                    return done(new Error('Incorrect data'));
                }
            });
            buffer.on('end', function () {
                bufferData = bufferData.join('');
                if (typeof randomData === 'string') {
                    if (randomData === bufferData) {
                        return done();
                    }
                    return done(new Error('Incorrect data'));
                }
            });

        });

        it('should buffer a stream with delay', function (done) {
            var bufferStream = new streamLib.Buffer(),
                randomStream = new streamLib.Random.Alphanumeric(),
                delayStream = new streamLib.Pipe.Delay(),

                randomChunks = [],
                bufferChunks = [];

            randomStream.countdown = BIGAMOUNT;
            delayStream.delay = 5;

            randomStream.on('data', function (chunk) {
                randomChunks.push(chunk.toString());
            });
            delayStream.on('data', function (chunk) {
                bufferChunks.push(chunk.toString());
            });

            randomStream
                .pipe(bufferStream)
                .pipe(delayStream);



            randomStream.on('end', function () {
                randomChunks = randomChunks.join('');
            });
            delayStream.on('end', function () {
                bufferChunks = bufferChunks.join('');
                if (typeof randomChunks === 'string') {
                    if (randomChunks === bufferChunks) {
                        return done();
                    }
                    return done(new Error('Incorrect data'));
                }
            });

        });
    });

    describe('LowerCase', function () {

        it('should turn into lower case', function (done) {
            var lowerCaseStream = new streamLib.LowerCase(),
                randomStream = new streamLib.Random.UpperCase(),
                randomChunks = [],
                upperCaseChunks = [];

            randomStream.countdown = SMALLAMOUNT;

            randomStream.on('data', function (chunk) {
                randomChunks.push(chunk.toString());
            });
            lowerCaseStream.on('data', function (chunk) {
                upperCaseChunks.push(chunk.toString());
            });

            randomStream.on('end', function () {
                randomChunks = randomChunks.join('');
            });

            lowerCaseStream.on('end', function () {
                upperCaseChunks = upperCaseChunks.join('');
                if (upperCaseChunks === randomChunks.toLowerCase() && upperCaseChunks !== randomChunks) {
                    return done();
                }
                return done(new Error('Wrong content'));
            });

            randomStream.pipe(lowerCaseStream);
        });
    });

    describe('UpperCase', function () {
        it('should turn into upper case', function (done) {
            var upperCaseStream = new streamLib.UpperCase(),
                randomStream = new streamLib.Random.LowerCase(),
                randomChunks = [],
                upperCaseChunks = [];

            randomStream.countdown = SMALLAMOUNT;

            randomStream.on('data', function (chunk) {
                randomChunks.push(chunk.toString());
            });
            upperCaseStream.on('data', function (chunk) {
                upperCaseChunks.push(chunk.toString());
            });

            randomStream.on('end', function () {
                randomChunks = randomChunks.join('');
            });

            upperCaseStream.on('end', function () {
                upperCaseChunks = upperCaseChunks.join('');
                if (upperCaseChunks === randomChunks.toUpperCase() && upperCaseChunks !== randomChunks) {
                    return done();
                }
                return done(new Error('Wrong content'));
            });

            randomStream.pipe(upperCaseStream);
        });
    });

    describe('Hex', function () {

        describe('Encoder', function () {
            it('should turn into hex', function (done) {
                var hexStream = new streamLib.hex.Encoder(),
                    testStr = 'just a test',
                    testHex = '6a75737420612074657374',
                    chunkText = '';

                hexStream.on('data', function (chunk) {
                    chunkText += chunk.toString();
                });
                hexStream.on('end', function () {
                    if (chunkText === testHex) {
                        return done();
                    }
                    return done(new Error('Wrong content'));
                });
                hexStream.write(testStr);
                hexStream.end();
            });
        });
        describe('Decoder', function () {
            it('should turn into hex', function (done) {
                var hexStream = new streamLib.hex.Decoder(),
                    testStr = 'just a test',
                    testHex = '6a75737420612074657374',
                    chunkText = '';

                hexStream.on('data', function (chunk) {
                    chunkText += chunk.toString();
                });
                hexStream.on('end', function () {
                    if (chunkText === testStr) {
                        return done();
                    }
                    return done(new Error('Wrong content'));
                });
                hexStream.write(testHex);
                hexStream.end();
            });
        });

    });


    describe('Unit', function () {

        it('should be able to make a unit of different pipes', function (done) {
            var unitStream = new streamLib.Unit(),
                randomStream = new streamLib.Random.LowerCase(),
                upperCaseStream = new streamLib.UpperCase(),
                hexEncoderStream = new streamLib.hex.Encoder(),
                gotData;

            randomStream.countdown = SMALLAMOUNT;

            hexEncoderStream
                .pipe(upperCaseStream);

            unitStream.on('data', function (chunk) {
                chunk = chunk.toString();

                if (chunk.toUpperCase() !== chunk) {
                    return done('The unit is not working');
                }
                gotData = true;
            });

            unitStream.on('end', function () {
                if (gotData) {
                    return done();
                }
                return done(new Error('Does not get any data'));
            });

            unitStream.setWritableStream(hexEncoderStream);
            unitStream.setReadableStream(upperCaseStream);

            randomStream
                .pipe(unitStream);

        });

        it('should be able to create an instrument from measure', function (done) {
            var unitStream = new streamLib.Unit({objectMode: true}),
                measureStream = new streamLib.Measure.Chunk(),
                randomStream = new streamLib.Random(),
                nullStream = new streamLib.Null(false),
                length = 0;
            unitStream.setReadableStream(measureStream);
            unitStream.setWritableStream(measureStream.measurePipe);

            randomStream.countdown = BIGAMOUNT;

            randomStream.pipe(unitStream);
            measureStream.measurePipe
                .pipe(nullStream);

            unitStream.on('data', function (chunk) {
                length += chunk.length;
            });

            unitStream.on('end', function () {
                if (length === BIGAMOUNT) {
                    return done();
                }
                return done(new Error('Wrong content streamed'));
            });

        });
    });

    describe('Concat', function () {
        // return it('is the question if we need this module here...');
        it('should pipe a single stream', function (done) {
            var concatStream = new streamLib.Concat(),
                randomStream = new streamLib.Random.Alphanumeric(),
                bufferStream = new streamLib.Buffer(),
                randomChunks = [],
                concatChunks = [];

            randomStream.countdown = SMALLAMOUNT;
            bufferStream
                .pipe(concatStream);

            randomStream.on('data', function (chunk) {
                randomChunks.push(chunk.toString());
            });
            concatStream.on('data', function (chunk) {
                concatChunks.push(chunk.toString());
            });

            randomStream.on('end', function () {
                randomChunks = randomChunks.join('');
            });
            concatStream.on('end', function () {
                concatChunks = concatChunks.join('');

                if (randomChunks === concatChunks) {
                    return done();
                }
                return done(new Error('Incorrect data'));
            });

            randomStream.pipe(bufferStream);
        });

        it('should pipe two streama', function (done) {
            var concatStream = new streamLib.Concat(),
                firstStream = new streamLib.Random.UpperCase(),
                secondStream = new streamLib.Random.LowerCase(),
                firstBuffer = new streamLib.Buffer(),
                secondBuffer = new streamLib.Buffer(),
                firstChunks = [],
                secondChunks = [],
                concatChunks = [];

            firstStream.countdown = SMALLAMOUNT;
            secondStream.countdown = SMALLAMOUNT;


            firstBuffer
                .pipe(concatStream);
            secondBuffer
                .pipe(concatStream);

            firstStream.on('data', function (chunk) {
                firstChunks.push(chunk.toString());
            });
            secondStream.on('data', function (chunk) {
                secondChunks.push(chunk.toString());
            });
            concatStream.on('data', function (chunk) {
                concatChunks.push(chunk.toString());
            });

            firstStream.on('end', function () {
                firstChunks = firstChunks.join('');
            });
            secondStream.on('end', function () {
                secondChunks = secondChunks.join('');
            });
            concatStream.on('end', function () {
                concatChunks = concatChunks.join('');
                if (firstChunks + secondChunks === concatChunks) {
                    return done();
                }
                return done(new Error('Incorrect data'));
            });

            firstStream.pipe(firstBuffer);
            secondStream.pipe(secondBuffer);
        });
    });

    describe('Sequencer', function () {

        it('should repeat the sequence without ending', function (done) {
            var sequenceStream = new streamLib.Sequencer(),
                even = true,
                count = 0;

            sequenceStream.write('first-');
            sequenceStream.write('second-');
            sequenceStream.end();

            sequenceStream.on('data', function (chunk) {
                count += 1;
                if (even) {
                    if (chunk.toString() !== 'first-') {
                        return done('Wrong content');
                    }
                } else {
                    if (chunk.toString() !== 'second-') {
                        return done('Wrong content');
                    }
                }

                even = !even;

                if (count >= 5) {
                    /*jslint nomen: true*/
                    sequenceStream._end();
                    /*jslint nomen: false*/
                }
            });

            sequenceStream.on('end', done);
        });
    });

    // describe('Sluice', function () {
    //     it('should pipe in normal state', function (done) {
    //         var sluiceSteam = new streamLib.Sluice(),
    //             firstPipe = new streamLib.Pipe(),
    //             secondPipe = new streamLib.Pipe(),
    //             nullStream = new streamLib.Null(false),
    //             randomStream = new streamLib.Random.Alphanumeric();
    //
    //         randomStream.countdown = SMALLAMOUNT;
    //
    //         firstPipe.on('end', done);
    //         sluiceSteam.on('end', done);
    //         //randomStream.on('end', done);
    //         secondPipe.on('end', done);
    //         secondPipe.on('end', done);
    //
    //         randomStream
    //             .pipe(firstPipe)
    //             .pipe(sluiceSteam)
    //             .pipe(secondPipe)
    //             .pipe(nullStream);
    //
    //
    //     });
    //     it('should get tests');
    // });
    //
    // describe('Beat', function () {
    //     it('should get tests');
    // });

    describe('Event', function () {
        var EventEmitter = require('events').EventEmitter;

        it('should not receive own events', function (done) {
            var eventStream = new streamLib.Event(),
                testObj = {},
                called;

            eventStream.receiveOnce('test', function () {
                if (!called) {
                    called = true;
                    return done(new Error('Received own event'));
                }
            });
            eventStream.send('test', testObj);
            eventStream.end();
            setTimeout(function () {
                if (!called) {
                    called = true;
                    return done();
                }
            }, 10);
        });

        it('should send and listen once', function (done) {
            var senderStream = new streamLib.Event(),
                receiverStream = new streamLib.Event(),
                testObj = {};

            receiverStream.receiveOnce('test', function (obj) {
                if (obj === testObj) {
                    return done();
                }
                return done(new Error('Wrong object received'));
            });

            senderStream.pipe(receiverStream);

            senderStream.send('test', testObj);
            senderStream.end();
        });
        it('should end an eventStream', function (done) {
            var senderStream = new streamLib.Event(),
                receiverStream = new streamLib.Event(),
                consumer = new streamLib.Null(false);

            receiverStream.on('end', function () {
                return done();
            });

            senderStream.pipe(receiverStream)
                .pipe(consumer);

            senderStream.end();
        });
        it('should be bindable to event emitters', function (done) {
            var senderStream = new streamLib.Event(),
                receiverStream = new streamLib.Event(),
                eventEmitter = new EventEmitter(),
                testObj = {};

            senderStream.augmentEmitter(eventEmitter);
            senderStream.pipe(receiverStream);

            receiverStream.receiveOnce('test', function (data) {
                if (data === testObj) {
                    return done();
                }
                return done(new Error('Wrong content emitted'));
            });

            eventEmitter.emit('test', testObj);
        });
        it('should be bindable to event emitters with prefix', function (done) {
            var senderStream = new streamLib.Event(),
                receiverStream = new streamLib.Event(),
                eventEmitter = new EventEmitter(),
                testObj = {};

            senderStream.augmentEmitter(eventEmitter, 'prefix-');
            senderStream.pipe(receiverStream);

            receiverStream.receiveOnce('prefix-test', function (data) {
                if (data === testObj) {
                    return done();
                }
                return done(new Error('Wrong content emitted'));
            });

            eventEmitter.emit('test', testObj);
        });
        it('should be bindable to event listerners', function (done) {
            var senderStream = new streamLib.Event(),
                receiverStream = new streamLib.Event(),
                eventEmitter = new EventEmitter(),
                testObj = {};


            eventEmitter.on('test', function (data) {
                if (data === testObj) {
                    return done();
                }
                return done(new Error('Wrong content emitted'));
            });

            receiverStream.augmentListener(eventEmitter);

            senderStream.pipe(receiverStream);

            senderStream.send('test', testObj);
            senderStream.end();
        });
        it('should be bindable to event listerners with prefix', function (done) {
            var senderStream = new streamLib.Event(),
                receiverStream = new streamLib.Event(),
                eventEmitter = new EventEmitter(),
                testObj = {};


            eventEmitter.on('prefix-test', function (data) {
                if (data === testObj) {
                    return done();
                }
                return done(new Error('Wrong content emitted'));
            });

            receiverStream.augmentListener(eventEmitter, 'prefix-');

            senderStream.pipe(receiverStream);

            senderStream.send('test', testObj);
            senderStream.end();
        });
        describe('Filter', function () {
            it('should filter events with a string', function (done) {
                var eventStream = new streamLib.Event(),
                    filterEventStream = new streamLib.Event.Filter('test'),
                    wrong = {},
                    right = {};

                eventStream.pipe(filterEventStream);

                filterEventStream.on('data', function (chunk) {
                    if (chunk.data === right) {
                        return done();
                    }
                    return done(new Error('Wrong event received'));
                });

                eventStream.send('wrong', wrong);
                eventStream.send('test', right);

            });
            it('should filter events with a regular expression', function (done) {
                var eventStream = new streamLib.Event(),
                    filterEventStream = new streamLib.Event.Filter(/^test$/),
                    wrong = {},
                    right = {};

                eventStream.pipe(filterEventStream);

                filterEventStream.on('data', function (chunk) {
                    if (chunk.data === right) {
                        return done();
                    }
                    return done(new Error('Wrong event received'));
                });

                eventStream.send('wrong', wrong);
                eventStream.send('test', right);

            });
        });
        describe('Prefix', function () {
            it('should prefix events with a string', function (done) {
                var senderStream = new streamLib.Event(),
                    prefixEventStream = new streamLib.Event.Prefix('test-'),
                    receiverStream = new streamLib.Event(),
                    wrong = {},
                    right = {},
                    gotWrong,
                    gotRight;

                senderStream.pipe(prefixEventStream)
                    .pipe(receiverStream);

                receiverStream.receive(/^test\-/, function (data) {
                    if (data === right) {
                        gotRight = true;
                    }
                    if (data === wrong) {
                        gotWrong = true;
                    }

                    if (gotRight && gotWrong) {
                        return done();
                    }
                });

                senderStream.send('wrong', wrong);
                senderStream.send('test', right);

            });

            it('should unprefix events with a string', function (done) {
                var senderStream = new streamLib.Event(),
                    unprefixEventStream = new streamLib.Event.Unprefix('test-'),
                    receiverStream = new streamLib.Event(),
                    wrong = {},
                    right = {},
                    gotWrong,
                    gotRight;

                senderStream.pipe(unprefixEventStream)
                    .pipe(receiverStream);

                receiverStream.receive(/^test|^wrong/, function (data) {
                    if (data === right) {
                        gotRight = true;
                    }
                    if (data === wrong) {
                        gotWrong = true;
                    }

                    if (gotRight && gotWrong) {
                        return done();
                    }
                });

                senderStream.send('test-wrong', wrong);
                senderStream.send('test-test', right);

            });
        });

        describe('Postfix', function () {
            it('should postfix events with a string', function (done) {
                var senderStream = new streamLib.Event(),
                    prefixEventStream = new streamLib.Event.Postfix('-test'),
                    receiverStream = new streamLib.Event(),
                    wrong = {},
                    right = {},
                    gotWrong,
                    gotRight;

                senderStream.pipe(prefixEventStream)
                    .pipe(receiverStream);

                receiverStream.receive(/\-test$/, function (data) {
                    if (data === right) {
                        gotRight = true;
                    }
                    if (data === wrong) {
                        gotWrong = true;
                    }

                    if (gotRight && gotWrong) {
                        return done();
                    }
                });

                senderStream.send('wrong', wrong);
                senderStream.send('test', right);

            });

            it('should unpostfix events with a string', function (done) {
                var senderStream = new streamLib.Event(),
                    unpostfixEventStream = new streamLib.Event.Unpostfix('-test'),
                    receiverStream = new streamLib.Event(),
                    wrong = {},
                    right = {},
                    gotWrong,
                    gotRight;

                senderStream.pipe(unpostfixEventStream)
                    .pipe(receiverStream);

                receiverStream.receive(/^test|^wrong/, function (data) {
                    if (data === right) {
                        gotRight = true;
                    }
                    if (data === wrong) {
                        gotWrong = true;
                    }

                    if (gotRight && gotWrong) {
                        return done();
                    }
                });

                senderStream.send('wrong-test', wrong);
                senderStream.send('test-test', right);

            });
        });
    });

    describe('Spawn', function () {
        it('should get content from child process (find .)', function (done) {
            var spawnStream = new streamLib.Spawn(),
                nullStream = new streamLib.Null(false);

            spawnStream.spawn('find', ['test'], {});

            spawnStream.on('end', done);


            spawnStream.pipe(nullStream);

            spawnStream.end();

        });

        it('should spawn cat as child process', function (done) {
            var spawnStream = new streamLib.Spawn(),
                testStr = 'just a test',
                resultStr = '';

            spawnStream.spawn('cat');

            spawnStream.on('data', function (chunk) {
                resultStr += chunk.toString();
            });

            spawnStream.on('end', function () {
                if (resultStr === testStr) {
                    return done();
                }
                return done(new Error('Wrong result'));
            });

            spawnStream.write(testStr);
            spawnStream.end();

        });

        it('should spawn cat as child process with big data amount', function (done) {
            var spawnStream = new streamLib.Spawn(),
                randomStream = new streamLib.Random(),
                length = 0;

            randomStream.countdown = BIGAMOUNT;
            spawnStream.spawn('cat');


            spawnStream.on('data', function (chunk) {
                length += chunk.length;
            });
            spawnStream.on('end', function () {
                if (length === BIGAMOUNT) {
                    return done();
                }
                return done(new Error('Wrong amount: ', length));
            });

            randomStream
                .pipe(spawnStream);

        });
    });
});