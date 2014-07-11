window.Views ||= {}

class Views.ApplicationView

  debounce: (func, threshold, execAsap) ->
    timeout = undefined
    debounced = ->
      delayed = ->
        func.apply obj, args  unless execAsap
        timeout = null
      obj = this
      args = arguments
      if timeout
        clearTimeout timeout
      else func.apply obj, args  if execAsap
      timeout = setTimeout(delayed, threshold or 100)

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
