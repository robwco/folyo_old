window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.ShowView extends Views.ApplicationView

  showReply: (replyPath) ->
    $reply = $(".reply-carrousel-item[data-path='#{replyPath}']")

    # sliding to the reply & resizing document height
    document.title = "Folyo - #{$reply.attr('data-title')}"
    $('#page-content .container').css('left', $reply.attr('data-left'))
    $('#page-content .container .main').height($reply.height())
    Widgets.FancyBox.cleanup()
    Widgets.FancyBox.enable()

    # updating header with reply content
    $header = $('.main-header')
    $('.avatar', $header).attr('src', $reply.attr('data-avatar'))
    $('.title span', $header).html($reply.attr('data-title'))
    $('.subtitle', $header).html($reply.attr('data-subtitle'))
    $('.reply-location', $header).html($reply.attr('data-location'))

    # updating actions
    $('#get-in-touch').attr('href', "/designers/#{$reply.attr('data-designer-id')}/messages/new")
    $('.shortlist.button').attr('href', $reply.attr('data-shortlist-path'))
    $('.hide.button').attr('href', $reply.attr('data-hide-path'))

    # updating next link
    if ($next_reply = $reply.next('.reply-carrousel-item')).length > 0
      @loadReplyContent($next_reply)
      $next_link = $('.subheader .next').show()
      $next_link.attr('href', $next_reply.attr('data-path'))
      $next_link.attr('title', "Next: #{$next_reply.attr('data-title')}")
      $('.avatar', $next_link).attr('src', $next_reply.attr('data-avatar'))
    else
      $('.subheader .next').hide()

    # updating prev link
    if ($prev_reply = $reply.prev('.reply-carrousel-item')).length > 0
      @loadReplyContent($prev_reply)
      $prev_link = $('.subheader .prev').show()
      $prev_link.attr('href', $prev_reply.attr('data-path'))
      $prev_link.attr('title', "Previous: #{$prev_reply.attr('data-title')}")
      $('.avatar', $prev_link).attr('src', $prev_reply.attr('data-avatar'))
    else
      $('.subheader .prev').hide()

    # updating status
    status = $reply.attr('data-status')
    if status == 'shortlisted'
      $('.reply-actions').removeClass('reply-hidden').addClass('reply-shortlisted')
      $reply.removeClass('reply-hidden').addClass('reply-shortlisted')
    else if status == 'hidden'
      $('.reply-actions').addClass('reply-hidden').removeClass('reply-shortlisted')
      $reply.addClass('reply-hidden').removeClass('reply-shortlisted')
    else
      $('.reply-actions').removeClass('reply-hidden').removeClass('reply-shortlisted')
      $reply.removeClass('reply-hidden').removeClass('reply-shortlisted')


  loadReplyContent: ($reply) ->
    if !$.trim($('.inner', $reply).html())
      $.ajax
        url: "#{$reply.attr('data-path')}"
        dataType: 'html'
        success: (data) -> $('.inner', $reply).html(data)

  popstateEventListener: (e) =>
    e.stopPropagation() && e.preventDefault()
    @showReply("#{document.location.pathname}#{document.location.search}")

  enableActionButtons: ->
    $('.shortlist.button, .hide.button').click (e) ->
      $btn = $(this)
      $reply = $('.reply-carrousel-item:visible,.reply-actions')
      $btn.addClass('spinning')
      $.ajax
        url: $btn.attr('href')
        type: 'POST'
        dataType: 'json'
        data:
          _method: 'PUT'
        success: (data) ->
          $btn.removeClass('spinning')
          $btn.tipsy('hide')
          if data.status == 'hidden'
            $btn.attr('title', 'Un-hide this reply')
            $reply.addClass('reply-hidden')
            $reply.removeClass('reply-shortlisted')
          else if data.status == 'shortlisted'
            $btn.attr('title', 'Remove from shortlist')
            $reply.addClass('reply-shortlisted')
            $reply.removeClass('reply-hidden')
          else
            $('.reply-actions a').each (i, r) -> $(r).attr('title', $(r).attr('default-title'))
            $reply.removeClass('reply-shortlisted')
            $reply.removeClass('reply-hidden')

      false

  render: ->
    super()

    # tooltips for iconic buttons
    $(".shortlist,.hide").tipsy(gravity: 'n')

    # overriding turbolinks history support for replies
    window.addEventListener 'popstate', @popstateEventListener

    @enableActionButtons()

    $('.designer-profile .subheader').on 'click', '.prev,.next', (e) =>
      path = if $(e.target).attr('href') then $(e.target).attr('href') else $(e.target).parent('a').attr('href')
      history.pushState(null, null, path)
      @showReply(path)
      false

  cleanup: ->
    window.removeEventListener 'popstate', @popstateEventListener
