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

  debounce: (func, threshold, execAsap) ->
    timeout = undefined
    debounced = ->
      delayed = ->
        func.apply obj, args  unless execAsap
        timeout = null
      obj = this
      args = arguments
      if timeout
        clearTimeout timeout
      else func.apply obj, args  if execAsap
      timeout = setTimeout(delayed, threshold or 100)

  enableAutoResize: ->
    @resizePrimarySection()
    debouncedResize = @debounce(@resizePrimarySection, 100, false)
    $(window).on 'resize', debouncedResize
    $(window).on 'onorientationchange', debouncedResize

  enableAnchorLinkScrolling: ->
    $("a[href*=#]").click (e) ->
      $('html, body').animate({ scrollTop: $( this.hash ).offset().top}, 500)
      false
