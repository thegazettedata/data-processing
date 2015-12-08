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
      "min": 3973,
      "max": 438307,
      "county-avg": 30934,
      "state-avg": 3062553
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
      "state-avg": 38.1
    }
  },
  "MEDIAN_HOUSEHOLD_INCOME": {
    "text": "Median household income",
    "text-before": "$",
    "text-after": "",
    "categories": {
      "subcategories": false,
      "min": 36326,
      "max": 73847,
      "county-avg": 0,
      "state-avg": 51843
    }
  },
  "POVERTY": {
    "text": "Poverty",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": false,
      "min": 6,
      "max": 22,
      "county-avg": 0,
      "state-avg": 12.4
    }
  },
  "RACE": {
    "text": "Race",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": true,
      "WHITE": {
        "text": "White",
        "county-avg": 0,
        "min": 80,
        "max": 100,
        "state-avg": 91.5
      },
      "BLACK": {
        "text": "Black",
        "county-avg": 0,
        "min": 0,
        "max": 10,
        "state-avg": 3.0
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
        "max": 8,
        "state-avg": 1.8
      },
      "OTHER": {
        "text": "Other",
        "county-avg": 0,
        "min": 0,
        "max": 8,
        "state-avg": 1.4
      },
      "TWO": {
        "text": "Two",
        "county-avg": 0,
        "min": 0,
        "max": 4,
        "state-avg": 1.9
      }
    }
  },
  "EDU": {
    "text": "Education",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": true,
      "LESS_THAN_HS": {
        "text": "Less than high school",
        "county-avg": 0,
        "min": 4,
        "max": 22,
        "state-avg": 9.0
      },
      "HS_GRAD": {
        "text": "High school grad",
        "county-avg": 0,
        "min": 17,
        "max": 47,
        "state-avg": 32.9
      },
      "SOME_COLLEGE": {
        "text": "Some college",
        "county-avg": 0,
        "min": 25,
        "max": 42,
        "state-avg": 32.3
      },
      "BACHELORS": {
        "text": "Bachelor's degree",
        "county-avg": 0,
        "min": 7,
        "max": 33,
        "state-avg": 17.7
      },
      "GRADUATE": {
        "text": "Graduate degree",
        "county-avg": 0,
        "min": 2,
        "max": 24,
        "state-avg": 8.0
      }
    }
  },
  "INDUSTRY": {
    "text": "Industry",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": true,
      "AG": {
        "text": "Agriculture",
        "county-avg": 0,
        "min": 0,
        "max": 17,
        "state-avg": 4.0
      },
      "CONSTRUCTION": {
        "text": "Construction",
        "county-avg": 0,
        "min": 3,
        "max": 12,
        "state-avg": 6.0
      },
      "MANUFACTURING": {
        "text": "Manufacturing",
        "county-avg": 0,
        "min": 6,
        "max": 33,
        "state-avg": 14.8
      },
      "RETAIL": {
        "text": "Retail",
        "county-avg": 0,
        "min": 7,
        "max": 19,
        "state-avg": 11.7
      },
      "FINANCE": {
        "text": "Finance",
        "county-avg": 0,
        "min": 2,
        "max": 23,
        "state-avg": 7.7
      },
      "EDUCATION": {
        "text": "Education",
        "county-avg": 0,
        "min": 17,
        "max": 41,
        "state-avg": 24.0
      },
      "ARTS": {
        "text": "Arts",
        "county-avg": 0,
        "min": 1,
        "max": 12,
        "state-avg": 7.5
      }
    }
  },
  "UNEMPLOYMENT": {
    "text": "Unemployment",
    "text-before": "",
    "text-after": "%",
    "categories": {
      "subcategories": false,
      "min": 1,
      "max": 6,
      "county-avg": 0,
      "state-avg": 3.5
    }
  }
}