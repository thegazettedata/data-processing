// Set view of Leaflet map based on screen size
var layer = new L.StamenTileLayer('toner-background');
var map = new L.Map('map', {
	center: new L.LatLng(42,-93.3),
	minZoom: 4,
	maxZoom: 10,
	zoom: 7,
	keyboard: false,
	boxZoom: false,
	doubleClickZoom: false,
	scrollWheelZoom: false,
	maxBounds: [[33.154799,-116.586914],[50.190089,-77.563477]]
});
map.addLayer(layer);

// City labels
city_labels = new L.FeatureGroup();

var cities = [
    [41.600545,-93.609106, 'Des Moines'],
    [41.97788,-91.665623, 'Cedar Rapids'],
    [41.523644,-90.577637, 'Davenport'],
    [42.499994,-96.400307, 'Sioux City'],
    [41.661128,-91.530168, 'Iowa City'],
    [42.492786,-92.342577, 'Waterloo'],
    [41.261944,-95.860833, 'Council Bluffs'],
    [42.034722,-93.62, 'Ames'],
    [42.500558,-90.664572, 'Dubuque'],
    [43.153573,-93.201037, 'Mason City'],
    [40.807653,-91.11289, 'Burlington'],
    [41.016029,-92.408302, 'Ottumwa'],
    [42.497469,-94.168016, 'Ft. Dodge']
];

// Put city labels on map
for (var num_cities = 0;  num_cities < cities.length; num_cities ++) {
    L.marker([
        cities[num_cities][0],
        cities[num_cities][1],
    ], {
        icon: L.divIcon({
            className: 'city-label-icons',
            html: '<div class="city-label-icons-circle"></div><p>' + cities[num_cities][2] + '</p>',
            // Set a markers width and height.
            iconSize: [90, 0]
        })
    }).addTo(city_labels);
}

// Show city labels
city_labels.addTo(map);
