window.Widgets ||= {}

class Widgets.LimitedText

  @enable: ->
    $(".limited").on "focus", ->
      $(this).trigger('keyup') # refresh current character count
      $(this).siblings(".character-counter-main-wrapper").fadeIn("fast")

    $(".limited").on "blur",  -> $(this).siblings(".character-counter-main-wrapper").fadeOut("fast")

    $('.limited').not('.isLimited').each  ->
      $(this).addClass('isLimited')
      limit_size_class = $(this).attr('class').split(' ').filter((i) -> i.match(/limited-\d+/)?)[0]
      if limit_size_class?
        limit_size = parseInt(limit_size_class.match(/limited-(\d+)/)[1], 10)
        if ($editor = $(this).siblings('.epiceditor')).length > 0
          $editor.css(height: "#{limit_size/2}px")
          $editor.data('epiceditor').reflow('height')

        $(this).characterCounter
          maximumCharacters: limit_size
          characterCounterNeeded: false

  @cleanup: ->
    $(".limited").off()
