$(document).ready(function(){

	var total=designers.length;
	console.log(total);
	$("#start").click(function(){
		console.log("START!!!!");
		if(total>0){
			var index = 0;
			t=setInterval(function () {
				var designer=designers[index].designer;
				var player_name=designer.dribble_username;
				var shot_id=designer.featured_shot;
				console.log(designer);
				if(player_name){
				
					if(shot_id){
						get_shot_url(
							shot_id,
							function(data){
								//success
									$.update(
								  	'/admin/designers/'+designer.id,
								  	{ featured_shot_url: data.image_url },
								  	function (response) {
											console.log("OK! ajax success for designer ID= "+response.designer.id);
										},
										function (response) {
											console.log("ERROR! ajax error for designer ID= "+response.designer.id);
										}
									);
							},
							function(){
								//error	
								console.log("error");
							}
						);
					}else{
						get_last_shot_url(
							player_name, 
							function(data){
									//success
										$.update(
									  	'/admin/designers/'+designer.id,
									  	{ featured_shot_url: data.shots[0].image_url },
									  	function (response) {
												console.log("OK! ajax success for designer ID= "+response.designer.id);
											},
											function (response) {
												console.log("ERROR! ajax error for designer ID= "+response.designer.id);
											}
										);
								}, 
							function(){
									//error
									console.log("error");
								}
						);
					}
				}
	
				if(index>=(total-1)){		
					clearInterval(t);		
				}
			  	index++;
			}, 1000);
		}
	});
	$("#abort").click(function(){
		console.log("ABORT!!!!");
		clearInterval(t);		
	});
});