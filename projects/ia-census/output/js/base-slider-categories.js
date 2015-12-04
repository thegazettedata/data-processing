// Info for each category
// Each category is explained

// text
// How you want the category worded on the page

// text_before
// text_after
// Where we store if we want to put any text before or after the range text
// For intance, a dollar sign median household income
// And a percentage sign after race percentages

// WITHIN CATEGORIES

// json-key
// The key in the GeoJSON that equals the current category
// Example: Black population is: RACE_BLACK

// min
// max
// Minimum and maximum values for each category
// Will adjust as reader adjusts slider

// county-avg
// state-avg
// County and state averages for each category

var slider_categories = {
  'POPULATION': {
    'text': 'Population',
    'text-before': '',
    'text-after': '',
    'categories': [{
      'min': 4000,
      'max': 432000,
      'county-avg': 30784,
      'state-avg': 3047646
    }]
  },
  'RACE': {
    'text': 'Race',
    'text-before': '',
    'text-after': '%',
    'categories': [{
      'json-key': 'WHITE',
      'text': 'White',
      'min': 82,
      'max': 99,
      'county-avg': '',
      'state-avg': 91.7
    },{
      'json-key': 'BLACK',
      'text': 'Black',
      'min': 0,
      'max': 9,
      'county-avg': '',
      'state-avg': 2.9
    }]
  }
  
};