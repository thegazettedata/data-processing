let nlp = require('nlp_compromise');
nlp.plugin(require('nlp-ngram'));
var fs = require('fs')
var util = require('util');

var year = process.argv[2];

// Open text file of year state of the state speech
var input_file = 'speeches/' + year + '.txt';

fs.readFile(input_file, 'utf8', function(err, data) {
  if (err) throw err;
	  
	var speech = nlp.text( data.replace(/--/g,' ') );
	var count = speech.ngram({min_count: 1})[0];
	var words = [];

	for(var i=0; i < count.length; i++){
		var speech_word = count[i]['word'];
		var speech_count = count[i]['count'];

		var terms = nlp.text(speech_word).terms();

		if (terms.length == 1) {
			if (terms[0] !== []) {
				// Pull both nouns and adjectives
				if (terms[0].pos['Noun'] || terms[0].pos['Adjective'] || terms[0].pos['Person'] || terms[0].pos['Place']) {
					// console.log(speech_word);

					words.push({
						'word': speech_word,
						'count': speech_count
					})
				}
			}
		}
	// Close for
	}

	var output_file = 'word-counts/' + year + '.csv';
	// var output_file = 'word-counts/' + year + '.json';

	// Clear out old information in file
	fs.writeFileSync(output_file , '', 'utf-8');

	fs.appendFileSync(output_file , 'word' + ',' + 'count' + '\n', 'utf-8'); 
	// fs.appendFileSync(output_file , 'var words = [\n', 'utf-8');

	// Objects for each word
	for(var i=0; i < words.length; i++){
		// All iterations except the last one
		if ( words.length !== (i + 1) ) {
			var data = util.inspect(words[i]) + ',\n';
		// Last iteration
		} else {
			var data = util.inspect(words[i]);
		}
		fs.appendFileSync(output_file , words[i]['word'] + ',' + words[i]['count'] + '\n', 'utf-8');
		// fs.appendFileSync(output_file , data, 'utf-8');
	}

	// fs.appendFileSync(output_file , '\n]', 'utf-8'); 

// Close read file
});