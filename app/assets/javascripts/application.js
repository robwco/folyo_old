//= require turbolinks
//= require jquery.turbolinks
//= require misc/parseURI.js
//= require map
//= require wysiwyg

//= require_self

head(function() {

  $(function() {

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
        , adjust: {
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

    $('.status-selector select').change(function(){
      var status_select=$(this);
      var designer_id=status_select.attr("name");
      var new_status=status_select.val();
      $.update(
        '/admin/designers/'+designer_id,
        { status: new_status },
        function (response) {
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

      if (url.charAt(url.length-1)=="/") {
        url = url.substring(0, url.length-1);
      }
      var designer_reply_url=url + "/" + designer_reply_id;

      if(li.hasClass("collapsed")){
        li.removeClass("collapsed");
        $.update(
            designer_reply_url,
            { collapsed: 0 }
        );
      } else {
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

});