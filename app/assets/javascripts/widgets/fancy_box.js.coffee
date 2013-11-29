window.Widgets ||= {}

class Widgets.FancyBox

  @enable: ->
    $(".lightbox").fancybox maxWidth: 400
    $fancyboxHolder = $('<div id="fancybox-holder"></div>').appendTo(document.body)
    $(".fancybox").each ->
      link = $(this).attr("href") + ".js"
      $(this).fancybox
        parent: $fancyboxHolder
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
