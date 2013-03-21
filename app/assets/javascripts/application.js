//= require misc/parseURI.js
//= require_self

$.extend({
  getUrlVars: function(){
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
});

$.ajaxSetup({
  beforeSend: function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript");
  }
});

$(document).ready(function(){

	// open all external links in a new tab
	// $("a").click(function() {
	//     link_host = this.href.split("/")[2];
	//     document_host = document.location.href.split("/")[2];
	//
	//     if (link_host != document_host) {
	//       window.open(this.href);
	//       return false;
	//     }
	//   });

	// if(typeof(console) === 'undefined') {
	//     var console = {}
	//     console.log = function() {};
	// };

   //just a comment

  $('.tooltip, .wysiwyg .toolbar li').not('.separator').qtip({
    position: {
        my: 'bottom center'  // Position my bottom center...
        ,at: 'top center' // at the bottom right of...
        ,target: false // my target
      ,adjust: {
             y: -8
          }
     }
  });
  $('.bottom-tip').qtip({
    position: {
        my: 'top center'  // Position my bottom center...
        ,at: 'bottom center' // at the bottom right of...
        ,target: false // my target
      ,adjust: {
             y: 8
          }
     }
  });

  $(".inline-hints").each(function(){
    var $input=$(this).parent().find("input, textarea");
    var $hint=$(this);

    $input.addClass("test");

    $input.focus(function(){
      $hint.addClass("in-focus");
    });

    $input.blur(function(){
      $hint.removeClass("in-focus");

    });
  });

	function shot_callback(shot, img, link, caption){
	      var shotIMGURL=shot.image_url;
	      var shotURL=shot.url;
	      img.attr("src", shotIMGURL);
	      link.attr("href", shotURL);
	      caption.html('<a href="'+shotURL+'">'+shot.title+'</a>');
	};
	$(".featured-work").each(function(){
		var $figure=$(this);
		var $link=$figure.find("a");
		var $img=$figure.find("img");
		var $caption=$figure.find(".caption");
		var $input=$figure.find("input");
		if($input.length>0){
		    $.getJSON("http://api.dribbble.com/shots/"+$input.val()+"?callback=?", function(data){
				shot_callback(data, $img, $link, $caption);
		    });
		}else{
		    $.getJSON("http://api.dribbble.com/players/"+$link.attr("title")+"/shots?callback=?", function(data){
				shot_callback(data.shots[0], $img, $link, $caption);
		    });
		}
	});

	$(".dribbble-work").each(function(){
		$(this).find("li").each(function(index, element){
			var $figure=$(this);
			var $link=$figure.find("a");
			var $img=$figure.find("img");
			var $caption=$figure.find(".caption");
			$.getJSON("http://api.dribbble.com/players/"+$link.attr("title")+"/shots?callback=?", function(data){
				console.log(index);
				console.log(data);
				console.log(data.shots);
				console.log(data.shots[index]);
				if(data.shots && data.shots.length>=index){
					shot_callback(data.shots[index], $img, $link, $caption);
				}
			});
		});
	});

	$(".mailchimp-text").focus(function(){
		$this = $(this);
	    $this.select();

	    // Work around Chrome's little problem
	    $this.mouseup(function() {
	        // Prevent further mouseup intervention
	        $this.unbind("mouseup");
	        return false;
	    });
	});


	function setCookie(){
		//console.log($.cookie('discount'))
		if($.cookie('discount')==null){
			var hnDiv=$("#hnwelcome");
			hnDiv.css('display', 'block').show();
			hnDiv.find("a").click(function(){
				hnDiv.slideUp("slow");
			});
			var myCookie=$.cookie('discount', 'HN20', { expires: 30});
		}
	};

	function clearCookie(){
		$.cookie('discount', null);
	};

	var referrer= parseUri(document.referrer).host;
	//console.log(referrer);
	if(referrer=="news.ycombinator.com"){
		setCookie();
	}

	var ref_user=$.getUrlVar("ref");
	if (ref_user != null) {
		$.cookie('ref_user', ref_user, { expires: 30});
		var clicky_custom = {};
	  	clicky_custom.goal = { name: 'Referred_by_designer', revenue: ref_user };
	}

	$('h1').click(function(){
		setCookie();
		//console.log("cookie set");
	});

	$('.status-selector select').change(function(){
		var status_select=$(this);
		var designer_id=status_select.attr("name");
		var new_status=status_select.val();
		$.update(
		  '/admin/designers/'+designer_id,
		  { status: new_status },
		  function (response) {
				//console.log(response.designer.status_id);
				status_select.parent().find(".checkmark").removeClass("hidden").fadeOut("slow");
			},
			function (response) {
				console.log("error");
				console.log(response.designer.status);
			}
		);
	});

	$(".collapse").click(function(){

		var link=$(this);
		var li=link.parent();
		var url=document.URL;
		var designer_reply_id=link.attr("href").substring(1);

		if(url.charAt(url.length-1)=="/"){
			url = url.substring(0, url.length-1);
		}
		var designer_reply_url=url+"/"+designer_reply_id;

		if(li.hasClass("collapsed")){
			li.removeClass("collapsed");
			$.update(
			  	designer_reply_url,
			  	{ collapsed: 0 }
				// 			  	,function (response) {
				// 	console.log(response);
				// }
			);
		}else{
			$(this).parent().addClass("collapsed");
			$.update(
			  	designer_reply_url,
			  	{ collapsed: 1 }
			);
		}
		return false;
	});

	$(".message").each(function(){
		var msg=$(this);
		var p=$(this).find("p");
		if(p.text().length>230){
			msg.addClass("long");
		}
	});
	$("#designer_reply_message").autoGrow();


	$('.limit').one("keydown",function(){
		$('.remaining').fadeIn("fast");
	});

	$(".coding-note").hide();
	$('input[name="job_offer[coding]"]').change(function(){
		if($(this).val()=="3"){
			$(".coding-note").fadeIn("fast");
		}else{
			$(".coding-note").fadeOut("fast");
		}
	});

	$(".lightbox").fancybox({
		maxWidth:400
	});

	$(".fancybox").each(function(){
		var link=$(this).attr("href")+".js";
		$(this).fancybox({
			width: 400,
			autoSize: false,
			height: 170,
			type: 'inline',
			content: '<div id="lightbox-content"></div>',
			beforeShow: function(){
				$.ajax({
					url: link,
					success: function(data) {
				  		$('#lightbox-content').html(data);
					},
					dataType: "html"
				});
			}
		});
	});

	$('.thread-link').click(function(){
		$(this).parents(".client").find(".threads").toggleClass("hidden");
		return false;
	});

	$(".designer-post .excerpt").removeClass("hidden");
	$(".designer-post .full").hide();
	$(".read-more").click(function(){
		$post=$(this).parents(".designer-post");
		$post.find(".excerpt").hide().end().find(".full").slideDown("fast");
		return false;
	});
	$(".hide").click(function(){
		$post=$(this).parents(".designer-post");
		$post.find(".full").slideUp("fast", function(){
			$post.find(".excerpt").show();
		});
		return false;
	});
});