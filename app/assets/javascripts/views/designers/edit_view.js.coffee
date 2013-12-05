window.Views.Designers ||= {}

class Views.Designers.EditView extends Views.ApplicationView

  paperclipable = undefined

  render: ->
    super()
    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()
    paperclipable = new Widgets.Paperclipable()
    paperclipable.enable()

  cleanup: ->
    paperclipable.cleanup()