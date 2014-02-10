window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.ShowView extends Views.ApplicationView

  render: ->
    super()
    $(".star,.hide").tipsy(gravity: 'n')