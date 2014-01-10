window.Views ||= {}

class Views.ApplicationView

  render: ->
    $('body').removeClass('no-js').addClass('js')
    $('body').addClass("js-animate") unless ($.browser.mozilla)

    Widgets.FancyBox.enable()
    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()

  cleanup: ->
    Widgets.FancyBox.cleanup()
    Widgets.MarkdownEditor.cleanup()
    Widgets.LimitedText.cleanup()

