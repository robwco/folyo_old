window.Views.JobOffers ||= {}

class Views.JobOffers.ShowView extends Views.ApplicationView

  render: ->
    super()
    Widgets.LimitedText.enable()