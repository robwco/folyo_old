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

  enableDesignerSelection: ->
    $('.designers-queue .designer a').click (e) =>
      e.preventDefault()
      @lockView()
      if url = $(e.target).parent('a').attr('href')
        $('.designers-queue .designer').removeClass('current')
        $(e.target).parents('.designer').addClass('current')
        $.get url, (html) =>
          $('.current-designer-pane').html(html)
          @watchFramesLoading()
          @enableSocialUrlSelection()

  render: ->
    super()
    @enablePanesResizing()
    @watchFramesLoading()
    @enableDesignerSelection()
    @enableSocialUrlSelection()

  cleanup: ->
    super()
    @unlockView()
