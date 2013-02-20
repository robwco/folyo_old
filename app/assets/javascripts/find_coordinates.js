$(document).ready(function(){

	$("#start").click(function(){
		console.log("START!!!!");
		var total=designers.length;
		console.log(total);
		if(total>0){
			var index = 0;
			t=setInterval(function () {
				var designer=designers[index].designer;
				var address=designer.location;
				get_coordinates(
						address,
						function(results){
							var designer_coordinates=results[0].geometry.location.toString().replace("(","").replace(")","");
							console.log(address+":  "+designer_coordinates);
							$.update(
						  	'/admin/designers/'+designer.id,
						  	{ coordinates: designer_coordinates },
						  	function (response) {
									console.log("OK! ajax success for designer ID= "+response.designer.id);
								},
								function (response) {
									console.log("ERROR! ajax error for designer ID= "+response.designer.id);
								}
							);
									
						},
						function(status){
							console.log("ERROR! designer ID= "+designer.id+"  "+address+"  "+status);
						}
				);
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