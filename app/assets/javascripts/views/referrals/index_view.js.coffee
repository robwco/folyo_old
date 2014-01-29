window.Views.Referrals ||= {}

class Views.Referrals.IndexView extends Views.ApplicationView

  render: ->
    super()
    @enableTwitterShare()
    @enableCopyPaste()

  enableTwitterShare: ->
    $('.twitter-share').on 'click', ->
      window.open($(this).attr('href'), '_blank', 'width=600,height=260,top=200,left=300')
      false

  enableCopyPaste: ->
    clip = new ZeroClipboard($('.clipboard-copy'))

    clip.on 'load', (client) ->
      $(clip.htmlBridge).tipsy(gravity: 'n')
      $(clip.htmlBridge).attr('title', 'Copy to clipboard')

    clip.on 'complete', (client, args) ->
      $(clip.htmlBridge)
        .prop('title', 'Copied!')
        .tipsy('show')



