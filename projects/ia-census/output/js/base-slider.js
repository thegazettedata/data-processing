var selected_categories = {};

// Called every time the slider is changed
function changeMapOnSlide(json_key, value) {
  var min = $("#slider-" + json_key).slider('values', 0);
  var min_comma = commaSeparateNumber(min);
  var max = $("#slider-" + json_key).slider('values', 1);
  var max_comma = commaSeparateNumber(max);
  var range_text = value['text-before'] + min_comma + ' to ' + value['text-before'] + max_comma + value['text-after'];

    // Add to object so we can filter more than one category at a time
  selected_categories[json_key] = [min, max];

  // Put text on the page letting reader know what the range of values is
  $(".current-" + json_key).html(range_text);

  // Loop through layers in GeoJSON on map and figure out if it matches with slider
  for (var parcel in geojson["_layers"]) {
    // Current value of property set by slider
    var current_parcel = geojson["_layers"][parcel]["feature"]["properties"][json_key];
    var current_properties = geojson["_layers"][parcel]["feature"]["properties"];

    // Match up with what's in the slider and in the county
    if (current_parcel >= min && current_parcel <= max) {
      // Show county if we have just one selected category
      // And it matches what's in the slider
      if (Object.keys(selected_categories).length === 1) {
        // Show the counties that apply
        geojson["_layers"][parcel].setStyle({
          fillOpacity: 1
        });
      } else {
        var county_show = true;

        // Check other selected categories and hide those that don't apply
        _.each(selected_categories, function (value, key) {
          // Hide counties that don't match up with other attributes selected
          if (current_properties[key] < value[0] || current_properties[key] > value[1]) {
            geojson["_layers"][parcel].setStyle({
              fillOpacity: 0.1
            });
            county_show = false;
          }
        }, this);
        
        // Show the counties that apply
        if ( county_show === true) {
          geojson["_layers"][parcel].setStyle({
            fillOpacity: 1
          });
        }
      }
    // If the county and slier don't match
    } else {
      // Set style of GeoJSON on map
      geojson["_layers"][parcel].setStyle({
        fillOpacity: 0.1
      });
    }
  // Close loop through geojson layers
  }
// Close slider function
}

// Creates the slider itself by calling jQuery UI
function createSliders(json_key, value, value_two) {
  // Call slider
  $( "#slider-" + json_key ).slider({
    range: true,
    min: value_two['min'],
    max: value_two['max'],
    values: [ value_two['min'], value_two['max'] ],
    slide: function( event, ui ) {
      // Change data show on map
      changeMapOnSlide(json_key, value);
    },
    change: function( event, ui ) {
      // Change data show on map
      changeMapOnSlide(json_key, value);
    }
  // Close slider function
  });
// Close create slider
}

// HTML for the sliders
function sliderHTML(json_key, value, value_two) {
  var min_comma = commaSeparateNumber(value_two['min']);
  var max_comma = commaSeparateNumber(value_two['max']);
  var range_text = value['text-before'] + min_comma + ' to ' + value['text-before'] + max_comma + value['text-after'];
  var county_avg = commaSeparateNumber(value_two['county-avg']);
  var state_avg = commaSeparateNumber(value_two['state-avg']);

  // HTML for slider
  var slider_html = '<span class="' + json_key + '">';
  slider_html += '<span class="slider-category-current current-' + json_key + '">' + range_text + '</span>';
  slider_html += '<div id="slider-' +  json_key + '"></div>';
  slider_html += '<span class="average">';
        
  // Show county average text
  if (county_avg !== '') {
    slider_html += 'County average: ' + value['text-before'] +  county_avg +  value['text-after'] + ' / '
  }
        
  // Show stage average text
  slider_html += 'State average: ' + value['text-before'] +  state_avg +  value['text-after'] + '</span>';
  slider_html += '</span>';

  return slider_html;
}

// This starts up the slider creation process
function intializeSliders() {
  // Loop through each category above and create a slider for each
  _.each(slider_categories, function (value, key) {
    var categories = value['categories'];

    // HTML for the label of the slider
    var slider_header_html = '<div class="slider-category ' + key + '">';
    slider_header_html += '<span class="slider-category-header">' + value['text'] + '</span>';

    // If we need a dropdown with our sliders
    // I.E. race would have a dropdown for white, black, asian, etc.
    if (categories.length > 1) {
      // Create the dropdown
      slider_header_html += ': <select class="dropdown"></select>';
      $('.slider-details-box').append(slider_header_html);

      // Where we will put the sliders
      // One will be shown and the rest hidden
      // They will then be toggled with the dropdown
      $('.' + key).append('<span class="dropdown-options-' + key + '">');

      _.each(categories, function (value_two, key_two) {
        var json_key = key + '_' + value_two['json-key'];
        // HTML for slider
        var slider_html = sliderHTML(json_key, value, value_two);

        // Append slider element to select
        $('.' + key + ' select').append('<option id="dropdown-' + json_key + '" value="' + json_key + '">' + value_two['text'] + '</option>');
        
        // Append to newly created DIV
        $('.dropdown-options-' + key).append(slider_html);
                
        // Create slider 
        createSliders(json_key, value, value_two);

        // Show only the slider for the first option
        if (key_two !== 0) { 
          $('.' + json_key).hide();
        }
      // Close each
      }, this);

    // Close if more than one category
    } else {
      $('.slider-details-box').append(slider_header_html);

      // HTML for slider
      var slider_html = sliderHTML(key, value, value['categories'][0]);
            
      // Append to newly created DIV
      $('.' + key).append(slider_html);

      // Create slider
      createSliders(key, value, value['categories'][0]);
    }

    // Close DIV
    $('.slider-details-box').append('</span></div>');

  // Close each
  }, this);
// Close create sliders
}