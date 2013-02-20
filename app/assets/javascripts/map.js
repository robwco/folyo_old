//= require misc/markerclusterer_compiled.js
//= require misc/oms.min.js
function toTitleCase(str){
	// see http://stackoverflow.com/questions/196972/convert-string-to-title-case-with-javascript/196991#196991
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}
function markerCenterMap(map, marker){ // center the map around a marker
	// get pixel coordinates of the clicked marker and substract 150px to account for the infoWindow
	pixelCoord=overlay.getProjection().fromLatLngToContainerPixel(marker.position);
	centerCoord=new google.maps.Point(pixelCoord.x,pixelCoord.y-150);
	// center map on clicked marker (minus 150px)
	newCoord=overlay.getProjection().fromContainerPixelToLatLng(centerCoord);
	map.setCenter(newCoord);
}
$(document).ready(function(){
	var gm=google.maps; // shortcut to google maps object
	var markersArray = [];	
	var maxZoomLevel = 9; // This is the maximum zoom level for the clusters
	var mapHeight=500;
	var mapWidth=920;
	var centerMap=true;
	var latlng = new gm.LatLng(40.7143528,-74.0059731);		

	// ------------------------------ GOOGLE MAPS -------------------------------
	var myOptions = {
		zoom: 2,
		center: latlng,
		mapTypeId: gm.MapTypeId.ROADMAP
	};
	var map = new gm.Map(document.getElementById("map_canvas"),myOptions);
	// close the infowindow when people click anywhere on the map
	gm.event.addListener(map, 'click', function(){
		iw.close();
	});

	// ------------------------------ OVERLAY OBJECT -------------------------------
	// create overlay object to expose the fromLatLngToContainerPixel and fromContainerPixelToLatLng methods
	overlay = new google.maps.OverlayView();
	overlay.draw = function() {};
	overlay.setMap(map);

	// -------------------------------- SPIDERFIER -------------------------------
	// see https://github.com/jawj/OverlappingMarkerSpiderfier
	var omsOptions={keepSpiderfied: true, markersWontMove: true, markersWontHide: true};
	var oms = new OverlappingMarkerSpiderfier(map, omsOptions);
	var iw = new gm.InfoWindow({
		disableAutoPan: true
	});
	oms.addListener('click', function(marker) {
		iw.setContent(marker.desc);
		iw.open(map, marker);
		if(centerMap){
			markerCenterMap(map, marker);
		}
	});
	oms.addListener('spiderfy', function(spiderfiedMarkers, unspiderfiedMarkers) {
		// do not center map on invididual markers as long as spiderfy is active
		centerMap=false;
		// instead, center map only on first spiderfied marker
		markerCenterMap(map, spiderfiedMarkers[0]);
		console.log("stop centering map");
	});
	oms.addListener('unspiderfy', function(spiderfiedMarkers, unspiderfiedMarkers) {
		centerMap=true;
		// resume centering map on normal markers
		console.log("start centering map again");
	});

	// ------------------------------ ITERATE OVER DESIGNERS -------------------------------
	// designers is a JSON object with all the designers ( designers=#{@designers.to_json(:include => :user)} )
	$.each(designers, function(i, val) {
		var locArray=val.designer.coordinates.split(",");
		var latlng=new gm.LatLng(locArray[0], locArray[1]);
		var designer=val.designer;
		var image_content="";
		var location_content='<p>'+toTitleCase(designer.location)+'</p>';
		var info_content='<h4><a href="/designers/'+designer.id+'">'+designer.user.full_name+'</a></h4>';
		var shot_url=designer.featured_shot_url;
		if(shot_url){
			// if designer has a Dribbble shot, add it to the map tooltip content
			image_content='<a href="/designers/'+designer.id+'"><img style="width:160px;" src="'+shot_url+'"/></a>'+
			'<h6 class="small">(Image via <a href="http://dribbble.com/'+designer.dribble_username+'">Dribbble</a>)</h6>'
		}

		var marker = new gm.Marker({				
			position: latlng, 
			map: map, 
			title:val.designer.location
		});
		marker.desc=location_content+info_content+image_content;
		// marker.infoWindow=infoWindow;
		markersArray.push(marker);
		// also add Marker to OverlappingMarkerSpiderify
		oms.addMarker(marker);  
	});
	
	// ------------------------------ MARKER CLUSTERER -------------------------------
	var markerClusterOptions = {maxZoom: maxZoomLevel};
	var markerCluster = new MarkerClusterer(map, markersArray, markerClusterOptions);
	markerCluster.onClick = function() { return multiChoice(markerCluster); }

});