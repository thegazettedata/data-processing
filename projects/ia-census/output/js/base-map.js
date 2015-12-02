// Set view of Leaflet map based on screen size
var layer = new L.StamenTileLayer('toner-background');
var map = new L.Map('map').setView([42,-93],7);

map.addLayer(layer);
