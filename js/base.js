// FUNCTIONS
String.prototype.splice = function(idx, rem, str) {
    return this.slice(0, idx) + str + this.slice(idx + Math.abs(rem));
};

// Used to capitalize first letter of string
function capitaliseFirstLetter(string) {
	return string.charAt(0).toUpperCase() + string.slice(1);
};

// Used to capitalize first letter of all words
function toTitleCase(str) {
    return str.replace(/\w\S*/g, function(txt){
    	first_letter = txt.charAt(0).toUpperCase();

    	// This captures words with an apostrophe as the second character
    	// And capitalizes them correctly
    	// Example: o'brien = O'Brien
    	if (txt.charAt(1) === "'") {
    		return first_letter + txt.charAt(1) + txt.charAt(2).toUpperCase() + txt.substr(3).toLowerCase();
    	} else {
    		return first_letter + txt.substr(1).toLowerCase();
    	}
    });
}

// Add commas to numbers over 1000
function commaSeparateNumber(val){
	while (/(\d+)(\d{3})/.test(val.toString())){
		val = val.toString().replace(/(\d+)(\d{3})/, '$1'+','+'$2');
	}
	return val;
}

// This removes special characters and spaces
function removeSpecialCharacters(string) {
    return string.replace(/[^\w\s]/gi, '').replace(/ /g,'');
}

// Capitalize first letter of string, lower case the rest
function capitalizeFirstLowercaseRest(string){
    return string.charAt(0).toUpperCase() + string.substr(1).toLowerCase();
}