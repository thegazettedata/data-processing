// The base styling for shapes on the map.
function baseGeojsonCounties(feature) {
	return {
		fillColor: '#333',
		fillOpacity: 0.1,
		weight: 1,
		color: '#333',
		opacity: 1
	};
}

function popupLayer(feature, layer) {
	// Does this feature have properties?
	if (feature.properties) {
		var properties = feature.properties;

		var popup_html = '<h3>' + properties['name'] + '</h3>';

		// Append popup
		layer.bindPopup(popup_html);
	// Close if properties
	}
}

function onEachFeature(feature, layer) {
	// layer.on({
	// 	mouseover: highlightFeature,
	// 	mouseout: resetHighlight
	// });

	// Create a popu for the layer
	popupLayer(feature, layer);
}

var geojson = L.geoJson(counties, {
	style: baseGeojsonCounties,
	onEachFeature: onEachFeature
}).addTo(map);