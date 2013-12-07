window.Widgets ||= {}

class Widgets.FancyBox

  @enable: ->
    $fancyboxHolder = $('<div id="fancybox-holder"></div>').appendTo(document.body)
    $(".fancybox").fancybox
      parent: $fancyboxHolder
