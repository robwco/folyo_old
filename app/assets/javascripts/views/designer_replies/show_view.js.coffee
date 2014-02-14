window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.ShowView extends Views.ApplicationView

  showReply: (replyPath) ->
    $reply = $(".reply-carrousel-item[data-path='#{replyPath}']")

    # sliding to the reply
    document.title = "Folyo - #{$reply.attr('data-title')}"
    $('#page-content .container').css('left', $reply.attr('data-left'))

    # updating header with reply content
    $header = $('.main-header')
    $('.avatar', $header).attr('src', $reply.attr('data-avatar'))
    $('.title span', $header).html($reply.attr('data-title'))
    $('.subtitle', $header).html($reply.attr('data-subtitle'))

    # updating next link
    if ($next_reply = $reply.next('.reply-carrousel-item')).length > 0
      $next_link = $('.subheader .next').show()
      $next_link.attr('href', $next_reply.attr('data-path'))
      $next_link.attr('title', "Next: #{$next_reply.attr('data-title')}")
      $('.avatar', $next_link).attr('src', $next_reply.attr('data-avatar'))
    else
      $('.subheader .next').hide()

    # updating prev link
    if ($prev_reply = $reply.prev('.reply-carrousel-item')).length > 0
      $prev_link = $('.subheader .prev').show()
      $prev_link.attr('href', $prev_reply.attr('data-path'))
      $prev_link.attr('title', "Previous: #{$prev_reply.attr('data-title')}")
      $('.avatar', $prev_link).attr('src', $prev_reply.attr('data-avatar'))
    else
      $('.subheader .prev').hide()

  popstateEventListener: (e) =>
    console.log('popstate fired!', e)
    e.stopPropagation()
    @showReply(document.location.pathname)

  render: ->
    super()

    $(".star,.hide").tipsy(gravity: 'n')

    window.addEventListener 'popstate', @popstateEventListener

    $('.designer-profile .subheader').on 'click', '.prev,.next', (e) =>
      path = if $(e.target).attr('href') then $(e.target).attr('href') else $(e.target).parent('a').attr('href')
      history.pushState(null, null, path)
      @showReply(path)
      false

  cleanup: ->
    window.removeEventListener 'popstate', @popstateEventListener
