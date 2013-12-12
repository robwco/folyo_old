window.Widgets ||= {}

class Widgets.FancyBox

  @enable: ->
    $fancyboxHolder = $('<div id="fancybox-holder"></div>').appendTo(document.body);
    $(".fancybox").fancybox(
      parent:       $fancyboxHolder,
      openEffect:   'none',
      closeEffect:  'none'
    )
    $(".swipebox").swipebox(hideBarsDelay: 0)

  @cleanup: ->
    $(".swipebox").off()
    $('#fancybox-holder').remove()
    $(".fancybox").off()

