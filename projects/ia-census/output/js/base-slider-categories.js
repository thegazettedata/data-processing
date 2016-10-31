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
  "POPULATION": {
    "text": "Population",
    "text-before": "",
    "text-after": "",
    "categories": {
      "subcategories": false,
      "min": 3937,
      "max": 445136,
      "county-avg": 31092,
      "state-avg": 3078116
    }
  },
  "MEDIAN_AGE": {
    "text": "Median age",
    "text-before": "",
    "text-after": "",
    "categories": {
      "subcategories": false,
      "min": 26,
      "max": 49,
      "county-avg": 0,
      "state-avg": 38
    }
  },
  "MEDIAN_HOUSEHOLD_INCOME": {
    "text": "Median household income",
    "text-before": "$",
    "text-after": "",
    "categories": {
      "subcategories": false,
      "min": 38275,
      "max": 74876,
      "county-avg": 0,
      "state-avg": 52716
    }
  },
  "POVERTY": {
    "text": "Poverty",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": false,
      "min": 6,
      "max": 23,
      "county-avg": 0,
      "state-avg": 12.6
    }
  },
  "RACE": {
    "text": "Race",
    "text-before": "",
    "text-after": "",
    "categories": {
      "subcategories": true,
      "WHITE": {
        "text": "White",
        "county-avg": 0,
        "min": 80,
        "max": 99,
        "state-avg": 91.4
      },
      "BLACK": {
        "text": "Black",
        "county-avg": 0,
        "min": 0,
        "max": 10,
        "state-avg": 3.1
      },
      "INDIAN": {
        "text": "Indian",
        "county-avg": 0,
        "min": 0,
        "max": 8,
        "state-avg": 0.3
      },
      "ASIAN": {
        "text": "Asian",
        "county-avg": 0,
        "min": 0,
        "max": 9,
        "state-avg": 1.9
      },
      "OTHER": {
        "text": "Other",
        "county-avg": 0,
        "min": 0,
        "max": 8,
        "state-avg": 1.3
      },
      "TWO": {
        "text": "Two",
        "county-avg": 0,
        "min": 0,
        "max": 3,
        "state-avg": 1.9
      }
    }
  },
  "EDU": {
    "text": "Edu",
    "text-before": "",
    "text-after": "",
    "categories": {
      "subcategories": true,
      "LESS_THAN_HS": {
        "text": "Less than hs",
        "county-avg": 0,
        "min": 4,
        "max": 22,
        "state-avg": 8.7
      },
      "HS_GRAD": {
        "text": "Hs grad",
        "county-avg": 0,
        "min": 16,
        "max": 46,
        "state-avg": 32.5
      },
      "SOME_COLLEGE": {
        "text": "Some college",
        "county-avg": 0,
        "min": 26,
        "max": 42,
        "state-avg": 32.4
      },
      "BACHELORS": {
        "text": "Bachelors",
        "county-avg": 0,
        "min": 6,
        "max": 33,
        "state-avg": 18.0
      },
      "GRADUATE": {
        "text": "Graduate",
        "county-avg": 0,
        "min": 2,
        "max": 25,
        "state-avg": 8.4
      }
    }
  },
  "INDUSTRY": {
    "text": "Industry",
    "text-before": "",
    "text-after": "",
    "categories": {
      "subcategories": true,
      "AG": {
        "text": "Ag",
        "county-avg": 0,
        "min": 0,
        "max": 18,
        "state-avg": 4.0
      },
      "CONSTRUCTION": {
        "text": "Construction",
        "county-avg": 0,
        "min": 3,
        "max": 11,
        "state-avg": 6.1
      },
      "MANUFACTURING": {
        "text": "Manufacturing",
        "county-avg": 0,
        "min": 5,
        "max": 34,
        "state-avg": 15.0
      },
      "RETAIL": {
        "text": "Retail",
        "county-avg": 0,
        "min": 7,
        "max": 18,
        "state-avg": 11.7
      },
      "FINANCE": {
        "text": "Finance",
        "county-avg": 0,
        "min": 2,
        "max": 23,
        "state-avg": 7.6
      },
      "EDUCATION": {
        "text": "Education",
        "county-avg": 0,
        "min": 17,
        "max": 41,
        "state-avg": 24.1
      },
      "ARTS": {
        "text": "Arts",
        "county-avg": 0,
        "min": 1,
        "max": 13,
        "state-avg": 7.4
      }
    }
  },
  "UNEMPLOYMENT": {
    "text": "Unemployment",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": false,
      "min": 2,
      "max": 7,
      "county-avg": 0,
      "state-avg": 3.5
    }
  }
}