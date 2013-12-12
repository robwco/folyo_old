window.Views.Designers ||= {}

class Views.Designers.EditView extends Views.ApplicationView

  paperclipable = undefined

  render: ->
    super()
    paperclipable = new Widgets.Paperclipable()
    paperclipable.enable()

  cleanup: ->
    super()
    paperclipable.cleanup()