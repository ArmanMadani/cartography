// Interactive heatmap of SF's homelessness complaints via 311
// Made Using Mapbox 

mapboxgl.accessToken = <TOKEN>;

var bounds = [
	[-122.573738, 37.678823], // Southwest coordinates
	[-122.336960, 37.856813]  // Northeast coordinates
]

var map = new mapboxgl.Map({
	container: 'map',
	style: 'mapbox://styles/mapbox/light-v9',
	center: [-122.4194, 37.7749],
	zoom: 5,
	interactive: true,
	maxZoom: 20, 
	minZoom: 1,
	maxBounds: bounds
});

var requests_url = 'https://cdn.rawgit.com/ArmanMadani/cartography/3ecd67af/data/homeless_requests.geojson'

map.on('load', function() {
	map.addSource('311Requests', {
		type: 'geojson',
		data: requests_url
	});

	map.addLayer({
		id: '311Requests-heat',
		type: 'heatmap',
		source: '311Requests',
		maxzoom: 15,
		paint: {
			'heatmap-intensity': {
				stops: [
					[11, 1],
					[15, 3]
				]
			},
			'heatmap-color': [
				'interpolate',
				['linear'],
				['heatmap-density'],
				 0, 'rgba(236,222,239,0)',
		         0.2, 'rgb(208,209,230)',
		         0.4, 'rgb(166,189,219)',
		         0.6, 'rgb(103,169,207)',
		         0.8, 'rgb(28,144,153)'
			],
			'heatmap-radius': {
				stops: [
					[11, 15],
					[14, 20]
				]
			},
			'heatmap-opacity': {
				default: 1,
				stops: [
					[14, 1],
					[15, 0]
				]
			},
		},
		'filter': ['==', ['string', ['get', 'year']], '2009']
	});

	map.addLayer({
		id: '311Requests-circle',
		type: 'circle',
		source: '311Requests',
		minzoom: 14,
		paint: {
			'circle-color': 'rgba(78, 107, 159, 0.4)',
			'circle-stroke-color': 'white',
			'circle-stroke-width': 1,
			'circle-opacity': {
				stops: [
					[14, 0],
					[15, 1]
				]
			}
		}
	})

	document.getElementById('slider').addEventListener('input', function(elem) {
		var year = String(parseInt(elem.target.value));
		// update the map
		map.setFilter('311Requests-heat', ['==', ['string', ['get', 'year']], year]);
		document.getElementById('active-year').innerText = year;
	});
})
