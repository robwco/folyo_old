window.Views.Site ||= {}

class Views.Site.HomeView extends Views.ApplicationView

  render: ->
    @enableAutoResize()
    @enableAnchorLinkScrolling()

  resizePrimarySection: ->
    ori = window.orientation
    viewportHeight = $(window).innerHeight()

    if $(window).width() > 640
      $('section.primary').css('min-height', viewportHeight)
      $('section.secondary').css('margin-top', viewportHeight)
    else
      $('section.primary').css('min-height', '')
      $('section.secondary').css('margin-top', '')

  enableAutoResize: ->
    @resizePrimarySection()
    debouncedResize = @debounce(@resizePrimarySection, 100, false)
    $(window).on 'resize', debouncedResize
    $(window).on 'onorientationchange', debouncedResize

  enableAnchorLinkScrolling: ->
    $("a[href*=#]").click (e) ->
      $('html, body').animate({ scrollTop: $( this.hash ).offset().top}, 500)
      false
