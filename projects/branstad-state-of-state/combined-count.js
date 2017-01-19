var fs = require('fs');
var util = require('util');
var csv = require("fast-csv");

var words = [];

// Use this to loop through each year's CSV
var year_iteration = 2012;

// Use this to stop iteration on the current year
var date = new Date();
var current_year = date.getFullYear();

var iter = 0;
function readStream() {
	fs.createReadStream("word-counts/" + year_iteration + ".csv")
		.pipe(csv())
		.on("data", function(data){
			// 
			var words_present = false;
			iter += 1;

			for (var num = 0; num < words.length; num++) {
				words[num]['count'] = parseInt(words[num]['count']);

				if (data[0] == words[num]['word'] && data[0] !== 'word') {
					words[num]['count'] += parseInt(data[1])

					words_present = true;
				}
			}

			if (!words_present && data[0] !== 'word') {
				words.push({
					'word': data[0],
					'count': data[1]
				})
			}
		})
		.on("end", function(){
			year_iteration += 1;
			
			if (year_iteration <= current_year) {
				readStream();
			} else {
				var output_file = 'word-counts/combined-years.csv';

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
			}
		});
}

readStream();