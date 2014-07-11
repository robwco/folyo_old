#= require ../../application_view

window.Views.Admin ||= {}
window.Views.Admin.Designers ||= {}

class Views.Admin.Designers.IndexView extends Views.ApplicationView

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
      $('.current-designer-frame').height($('.current-designer-pane').height() - $('.current-designer-info').height())
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

  enableSocialUrlSelection: ->
    $('.social-urls').click (e) ->
      e.preventDefault()
      $target = $(e.target)
      return if $target.hasClass('disabled')
      iframeKind = $target.attr('data-profile')
      $('.social-urls a').removeClass('current')
      $target.addClass('current')
      $('.current-designer-pane iframe').hide()
      $(".current-designer-pane iframe.#{iframeKind}").show()


  enableDesignerSelection: ->
    $('.designers-queue .designer a').click (e) =>
      @lockView()
      if url = $(e.target).parent('a').attr('href')
        $.get url, (html) =>
          $('.current-designer-pane').html(html)
          @watchFramesLoading()
          @enableSocialUrlSelection()
      false

  render: ->
    super()

    @enablePanesResizing()
    @enableDesignerSelection()
    @lockView()
    $('.social-urls a').removeClass('disabled')
    @enableSocialUrlSelection()


  cleanup: ->
    super()
    @unlockView()

  # show_checkmark: ($status_select) ->
  #   $status_select.parent().find(".checkmark").removeClass("hidden").fadeOut "slow"
  #
  # update_designer: (url, data, callback) ->
  #   data['_method'] = 'PUT'
  #   $.ajax
  #     url:  url
  #     type: 'POST'
  #     dataType: 'json'
  #     data: data
  #     success: callback
  #
  # render: ->
  #   super()
  #
  #   #$('html, body').animate({ scrollTop: $("#page-content").offset().top}, 300)
  #
  #   $(".status-selector select").change (e) =>
  #     $status_select = $(e.target)
  #     designer_url = $status_select.attr("data-url")
  #     new_status = $status_select.val()
  #     if new_status == 'rejected'
  #       $status_select.siblings('.rejection-section').show()
  #     else
  #       @update_designer designer_url, { status: new_status }, =>
  #         @show_checkmark($status_select)
  #
  #   $('.reject-btn').click (e) =>
  #     e.preventDefault()
  #     $btn = $(e.target)
  #     $status_select = $btn.parent().siblings('select')
  #     designer_url = $status_select.attr("data-url")
  #     rejection_message = $btn.siblings('.text').children('textarea').val()
  #     @update_designer designer_url, { status: 'rejected', rejection_message: rejection_message }, =>
  #       $btn.parent().hide()
  #       @show_checkmark($status_select)
