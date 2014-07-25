#= require ../../application_view

window.Views.Admin ||= {}
window.Views.Admin.Designers ||= {}

class Views.Admin.Designers.PendingView extends Views.ApplicationView

  # prevents window scrolling when designer-queue is being scrolled
  enableScrolling: ($pane) ->
    height = $pane.height()
    scrollHeight = $pane.get(0).scrollHeight
    $pane.off 'mousewheel'
    $pane.on 'mousewheel', (e, d) ->
      e.preventDefault() if (this.scrollTop == (scrollHeight - height) && d < 0) or (this.scrollTop == 0 && d > 0)

  # resize automatically all panes when browser is resized
  enablePanesResizing: ->
    resizePanes = =>
      $('.current-designer-pane').width($(window).width() - $('.designers-queue').width())
      height = $('.current-designer-pane').height() - $('.current-designer-info').height()
      $('.current-designer-frame').height(height)
      $('.designers-queue ul.designers').height(height)
      @enableScrolling($('.designers-queue .designers'))
    debouncedResize = @debounce(resizePanes, 100, false)
    $(window).on 'resize', debouncedResize
    $(window).on 'onorientationchange', debouncedResize
    resizePanes()

  lockView: ->
    $('html, body').animate({ scrollTop: document.body.scrollHeight}, 500)
    $('.up').show().on 'click', @unlockView
    $('.current-designer-pane').on 'mousewheel', (e) -> false

  unlockView: ->
    $('html, body').animate({ scrollTop: 0}, 500)
    $('.current-designer-pane').off 'mousewheel'
    $('.up').hide()

  watchFramesLoading: ->
    $('.current-designer-pane iframe').load (e) ->
      iframeKind = e.target.className
      $(".social-urls a[data-profile=#{iframeKind}]").removeClass('disabled')
    $('.current-designer-pane iframe').each (i, frame) ->
      $frame = $(frame)
      $frame.attr('src', $frame.attr('data-src'))

  enableSocialUrlSelection: ->
    $('.social-urls').click (e) =>
      e.preventDefault()
      @lockView()
      $target = $(e.target).parents('a')
      return if $target.hasClass('disabled')
      iframeKind = $target.attr('data-profile')
      $('.social-urls a').removeClass('current')
      $target.addClass('current')
      $('.current-designer-pane iframe').hide()
      $(".current-designer-pane iframe.#{iframeKind}").show()

  enableModerationActions: ->
    update_designer = (url, data, callback) ->
      data['_method'] = 'PUT'
      $.ajax({url: url, type: 'POST', dataType: 'json', data: data, success: callback})

    callback = (data) =>
      $('.queue-counter .counter').html(data.designer_count)
      $('.designers-queue .designer.current').remove()
      @selectDesigner(data.next_designer_path)

    $('.moderation-actions .accept-profile').click (e) =>
      update_designer $(e.target).parents('a').attr('href'), { status: 'accepted' }, callback
      false

    $('.moderation-actions .reject-profile').fancybox(type: 'ajax', afterShow: =>
      $rejectBox = $('.moderation-reject-designer')
      console.log "afterLoad", $('form', $rejectBox).length
      $('form', $rejectBox).on 'submit', (e) =>
        e.preventDefault()
        update_designer $rejectBox.attr('data-path'), { status: 'rejected', rejection_message: $('input[type=text]', $rejectBox).val()  }, (data) =>
          $.fancybox.close()
          callback(data)
    )

  selectDesigner: (path) ->
    @lockView()
    history.pushState(null, null, path)
    $('.designers-queue .designer').removeClass('current')
    $designer = $(".designers-queue .designer a[href='#{path}']").parents('.designer')
    $designer.addClass('current')
    $.get path, (html) =>
      $('.current-designer-pane').html(html)
      @watchFramesLoading()
      @enableSocialUrlSelection()
      @enableModerationActions()

  popstateEventListener: (e) =>
    e.stopPropagation() && e.preventDefault()
    @selectDesigner(document.location.pathname)

  enableDesignerSelection: ->
    # overriding turbolinks history support for replies
    window.addEventListener 'popstate', @popstateEventListener
    $('.designers-queue .designer a').click (e) =>
      e.preventDefault()
      if path = $(e.target).parent('a').attr('href')
        @selectDesigner(path)

  render: ->
    super()
    @enablePanesResizing()
    @watchFramesLoading()
    @enableDesignerSelection()
    @enableSocialUrlSelection()
    @enableModerationActions()

  cleanup: ->
    super()
    @unlockView()
    window.removeEventListener 'popstate', @popstateEventListener
