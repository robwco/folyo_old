window.Views.Referrals ||= {}

class Views.Referrals.IndexView extends Views.ApplicationView

  render: ->
    super()
    new ZeroClipboard($(".clipboard-copy"))