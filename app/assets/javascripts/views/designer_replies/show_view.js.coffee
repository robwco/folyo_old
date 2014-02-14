window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.ShowView extends Views.ApplicationView

  render: ->
    super()

    $(".star,.hide").tipsy(gravity: 'n')

    $('.designer-profile').on 'click', '.prev,.next', (e) ->
      path = if $(e.target).attr('href') then $(e.target).attr('href') else $(e.target).parent('a').attr('href')
      $reply = $(".reply-carrousel-item[data-path='#{path}']")
      $('#page-content .container').css('left', $reply.attr('data-left'))

      # updating header
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

      false