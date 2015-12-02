function onEachFeature(feature, layer) {
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
    }
}

L.geoJson(counties, {
    onEachFeature: onEachFeature
}).addTo(map);