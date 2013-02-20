$(document).ready(function(){
	var network=$.getUrlVar("network");
	var campaign=$.getUrlVar("campaign");
	var ad=$.getUrlVar("ad");
	if (network != null) {
		_kmq.push(['set', {'Campaign Source':network}]);
	}
	if (campaign != null) {
		_kmq.push(['set', {'campaign':campaign}]);
	}
	if (ad != null) {
		_kmq.push(['set', {'ad':ad}]);
	}

});