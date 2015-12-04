// The base styling for shapes on the map.
function baseGeojsonCounties(feature) {
	return {
		fillColor: '#333',
		fillOpacity: 0.9,
		weight: 1,
		color: '#FFF',
		opacity: 1
	};
}

function highlightFeature(e) {
	var layer = e.target;
	layer.setStyle({
		weight: 3
	});

	if (!L.Browser.ie && !L.Browser.opera) {
		layer.bringToFront();
	}
}

function resetHighlight(e) {
	var layer = e.target;
	layer.setStyle({
		weight: 1
	});

	if (!L.Browser.ie && !L.Browser.opera) {
		layer.bringToBack();
	}
}

function popupLayer(feature, layer) {
	// Does this feature have properties?
	if (feature.properties) {
		var properties = feature.properties;

		var popup_html = '<h3>' + properties['name'] + '</h3>';
		popup_html += '<div><strong> Education - BA:</strong> '  + properties['EDU_BACHELORS'] + '</div>';
		popup_html += '<div><strong> Industry - AG:</strong> '  + properties['INDUSTRY_AG'] + '</div>';
		popup_html += '<div><strong> Median age:</strong> '  + properties['MEDIAN_AGE'] + '</div>';
		popup_html += '<div><strong> Median household income:</strong> '  + properties['MEDIAN_HOUSEHOLD_INCOME'] + '</div>';
		popup_html += '<div><strong> Population:</strong> '  + properties['POPULATION'] + '</div>';
		popup_html += '<div><strong> Poverty status:</strong> '  + properties['POVERTY_STATUS'] + '</div>';
		popup_html += '<div><strong> Race - white:</strong> '  + properties['RACE_WHITE'] + '</div>';
		popup_html += '<div><strong> Unemployment:</strong> '  + properties['UNEMPLOYMENT'] + '</div>';

		// Append popup
		layer.bindPopup(popup_html);
	// Close if properties
	}
}

function onEachFeature(feature, layer) {
	layer.on({
		mouseover: highlightFeature,
		mouseout: resetHighlight
	});

	// Create a popu for the layer
	popupLayer(feature, layer);
}

var geojson = L.geoJson(counties, {
	style: baseGeojsonCounties,
	onEachFeature: onEachFeature
}).addTo(map);