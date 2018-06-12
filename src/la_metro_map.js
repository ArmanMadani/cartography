// An interactive map of LA's Metro System 
// Made using Mapbox

mapboxgl.accessToken = 'pk.eyJ1IjoiYW1hZGFuaSIsImEiOiJjamNyNDdpZmQwOWhwMnhrY2RlaG1kN3pnIn0.T5vKsyQ_4BCO_oXNIp3MJg';

var bounds = [
	[-118.708604, 33.670143], // Southwest coordinates
	[-117.346309, 34.264393]  // Northeast coordinates
]

var map = new mapboxgl.Map({
	container: 'map',
	style: 'mapbox://styles/mapbox/light-v9',
	center: [-118.133, 34.030],
	zoom: 9,
	interactive: true,
	maxZoom: 12.5, 
	minZoom: 9,
	maxBounds: bounds
});

var stations_url = 'https://rawgit.com/ArmanMadani/ae84c78c19773c566b606bfb9fffe6f1/raw/0efa376b6f41fbc4c40878bd32041b981952f21b/la_stations.geojson';

var routes_url = 'https://rawgit.com/ArmanMadani/833f541aa0fb9d2855d9c6425708b33e/raw/f109b7578567a8b416b148db96bf2d5a62c17f60/la_routes.geojson'

map.on('load', function() {
	map.addSource('stations', {
		type: 'geojson',
		data: stations_url,
	});

	map.addLayer({
		'id': 'stations',
		'type': 'circle',
		'source': 'stations',
		'paint': {
			'circle-radius': 2.75,
			'circle-stroke-width': 2,
			'circle-opacity': 0.8,
			'circle-color': ['get', 'marker-color']
		}
	});

	map.addSource('routes', {
		type: 'geojson',
		data: routes_url
	});

	map.addLayer({
		'id': 'routes',
		'type': 'line',
		'source': 'routes',
		'paint': {
			'line-width': 3,
			'line-opacity': 0.4,
			'line-color': ['get', 'color']
		}
	});

	var popup = new mapboxgl.Popup({
		closeButton: false,
		closeOnClick: false
	});

	map.on('mouseenter', 'stations', function(elem) {
		map.getCanvas().style.cursor = 'pointer';
		var coordinates = elem.features[0].geometry.coordinates.slice();
		var name = elem.features[0].properties.name;
		var lines = elem.features[0].properties.line;
		var dateOpened = elem.features[0].properties.dateOpened;
		var popupHTMLContent = '<center><h3>' + 
        	name + '</h3></center><ul>' +
        	'<li>Line(s): ' + lines + '</li>' +
        	'<li>Date Opened/Projected Date: ' + dateOpened + '</li>' + 
        	'</ul>';

		// Ensure that if the map is zoomed out such that multiple
        // copies of the feature are visible, the popup appears
        // over the copy being pointed to. 
        // Courtesy: mapbox documentation
        while (Math.abs(elem.lngLat.lng - coordinates[0]) > 180) {
            coordinates[0] += elem.lngLat.lng > coordinates[0] ? 360 : -360;
        }

        popup.setLngLat(coordinates)
        	.setHTML(popupHTMLContent)
        	.addTo(map)
	});

	map.on('mouseleave', 'stations', function() {
		map.getCanvas().style.cursor = '';
		popup.remove();
	});
});