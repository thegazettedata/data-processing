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

_.each(caseys, function(val, num) {
	var lat = val['latitude'];
	var long = val['longitude'];

	var circle = L.circleMarker([lat, long], {
		'radius': 5,
		'color': '#FFF',
		'weight': 1,
		'opacity': 1,
		'fillColor': '#8856a7',
		'fillOpacity': 0.8
	}).addTo(map);

	
});