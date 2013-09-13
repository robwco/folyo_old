window.Views ||= {}

class Views.ApplicationView

  render: ->
    $('body').removeClass('no-js').addClass('js')
    $('body').addClass("js-animate") unless ($.browser.mozilla)

    Widgets.FancyBox.enable()

  cleanup: -> # empty, must be implemented by child classes

