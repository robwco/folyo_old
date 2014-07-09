window.Views.JobOffers ||= {}

class Views.JobOffers.ShowView extends Views.ApplicationView

  render: ->
    super()
    Widgets.LimitedText.enable()
    $('.prompt-nothanks').click (e) ->
      e.preventDefault()
      $('.upload-projects-prompt').fadeOut('fast')