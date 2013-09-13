window.Views.Designers ||= {}

class Views.Designers.EditView extends Views.ApplicationView
  render: ->
    super()
    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()