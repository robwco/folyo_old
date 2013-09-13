window.Views.Users ||= {}
window.Views.Users.Registrations ||= {}

class Views.Users.Registrations.NewView extends Views.ApplicationView

  render: ->
    super()
    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()
