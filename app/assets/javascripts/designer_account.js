// takes a city name as plain text, and makes a Google Maps API query to get the coordinates
function get_coordinates(address, success_callback, error_callback){
	var geocoder = new google.maps.Geocoder();
	if (geocoder) {
		geocoder.geocode({ 'address': address }, function (results, status) {
			$(".loading").removeClass("loading");
			if (status == google.maps.GeocoderStatus.OK) {
				success_callback(results);
			}else {
				error_callback(status);
			}
		});
	}else{
		error();
	}
}

// takes a shot ID and gets the image URL
function get_shot_url(shot_id, success_callback, error_callback){
	jsonp_call("http://api.dribbble.com/shots/"+shot_id+"?callback=?", success_callback, error_callback);
}

// takes a player name and gets their last shot url
function get_last_shot_url(player_name, success_callback, error_callback){
	jsonp_call("http://api.dribbble.com/players/"+player_name+"/shots?callback=?", success_callback, error_callback);
}

function jsonp_call(api_url, success_callback, error_callback){
	// http://code.google.com/p/jquery-jsonp/wiki/APIDocumentation
	// use $.jsonp instead of $.ajax because the error callback of $.ajax is not triggered by the 404
	$.jsonp({
		url: api_url,
		success: function(data, textStatus) {
			$('.loading').removeClass("loading");
			success_callback(data);
		},
		error: function(){
			$('.loading').removeClass("loading");
			error_callback();
		}
	});
}

function showError(errorDiv){
	errorDiv.fadeIn("fast").removeClass("hidden");
}
function hideError(errorDiv){
	if(!errorDiv.hasClass("hidden")){
		errorDiv.fadeOut("fast").addClass("hidden");
	}
}

$(document).ready(function(){

	if($('.limit-80').length){
		$('.limit-80').limit('80','.chars-left');
	}

	$("#designer_location").change(function(){
		var address=$(this).val();
		$(this).parent().addClass("loading");
		$errorDiv=$("#ambiguous_location");
		get_coordinates(
			address,
			function(results){
				//success
				$("#designer_coordinates").val(results[0].geometry.location.Ma+","+results[0].geometry.location.Na);
				hideError($errorDiv);
			},
			function(){
				//error
				showError($errorDiv);
			}
		);
	});

	$("#designer_featured_shot").change(function(){
		var shot_id=$(this).val();
		var parentLi=$(this).parent();

		if(shot_id!=""){
			$errorDiv=$("#bad_shot");
			get_shot_url(
				shot_id,
				function(data){
					//success
					$("#designer_featured_shot_url").val(data.image_url);
					hideError($errorDiv);
				},
				function(){
					//error
					showError($errorDiv);
				}
			);
		}else{
			// if designer removes their featured shot ID, replace the URL with the latest shot by default
			if(player_name=$("#designer_dribble_username").val()){
				get_last_shot_url(
					player_name,
					function(data){
						//success
						$("#designer_featured_shot_url").val(data.shots[0].image_url);
					},
					function(){
						//error
					}
				);
			}
		}
	});
});