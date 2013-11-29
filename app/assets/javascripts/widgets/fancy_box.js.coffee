window.Widgets ||= {}

class Widgets.FancyBox

  @enable: ->
    $(".lightbox").fancybox maxWidth: 400
    $(".fancybox").each ->
      console.log 'toto'
      link = $(this).attr("href") + ".js"
      $(this).fancybox
        width: 400
        autoSize: false
        height: 170
        type: "inline"
        content: "<div id=\"lightbox-content\"></div>"
        beforeShow: ->
          $.ajax
            url: link
            success: (data) ->
              $("#lightbox-content").html data
            dataType: "html"
