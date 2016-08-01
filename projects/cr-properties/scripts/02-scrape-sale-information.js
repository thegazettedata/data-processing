var request = require("request");
var cheerio = require("cheerio"); 
var fs = require("fs");
var csv = require("fast-csv");

// Read, write files
var read_stream_file = fs.createReadStream('scripts/2016-properties-not-in-2008-need-scraped.csv');
var write_stream_file = fs.createWriteStream('scripts/2016-properties-not-in-2008-scraped.csv');

// URL we're scraping
var url_params = "http://cedarrapids.iowaassessors.com/parcel.php?parcel=";

var rows = 0;

function trimText(text) {
  return text.text().trim().replace(/,/g, '');
}

// Using jQuery, we pull out the data we need on page
function scrapeOutput(body, csv_data) {
  var $ = cheerio.load(body);
      
  // Our sale data is within DIV with class of saleData
  var sale_data = $('.saleData').first();

  // Get data and return as comma separated so we can add to CSV
  var columns = [];
  var column_one = trimText( $(sale_data).find('.saleColumn') );
  var column_two = trimText( $(sale_data).find('.saleColumn2') );
  var column_three = trimText( $(sale_data).find('.saleColumn1') );
  var column_four = trimText( $(sale_data).find('.saleColumn3') );
  columns.push(column_one, column_two, column_three, column_four);

  // Write original data to CSV
  write_stream_file.write( csv.join(',') );
  
  // Write newly scraped data to CSV
  if (rows === 0) {
    // Write headers for first row
    write_stream_file.write(',Sale date,Amount,Non-Useable Transaction Code,Recording' + '\n');
  } else {
    write_stream_file.write(',' + columns.join(',') + '\n');
  }

  rows += 1;
}

// Scrape URL
function scrapeURL(geo_id, csv_data, callback) {
  csv = csv_data;

  // Set URL for this particular CSV
  var url = url_params + geo_id;
  console.log('Now scraping: ' + url);
  
  request({
    url: url,
  }, function (error, response, body) {
    if (error || response.statusCode !== 200) {
      return callback(error || {statusCode: response.statusCode});
    }
    callback(null, body);
  });
// Close function
}

// Request URL or return error
function scrape(geo_id, csv_data) {
  scrapeURL(geo_id, csv_data, function(error, body) {
    if (error) {
      console.log(error);
    } else {
      scrapeOutput(body); 
    }
  });
}

// Loop through our read CSV
var read_stream = csv()
  .on("data", function(data){
    var data_object = data;
    var data_geo_id = data[0];
    
    // Pause data
    read_stream.pause();

    scrape(data_geo_id, data_object);

    // Call scraper every second
    setTimeout(() => {
      read_stream.resume();
    }, 10000);
  })
  .on("end", function(){
    console.log("Done scraping URLs");
  });

// Read CSV file
read_stream_file.pipe(read_stream)