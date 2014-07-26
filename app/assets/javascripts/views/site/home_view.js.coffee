window.Views.Site ||= {}

class Views.Site.HomeView extends Views.ApplicationView

  render: ->
    @enableAutoResize()
    @enableAnchorLinkScrolling()
    @loadHeatMap()

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

  loadHeatMap: ->
    # heatmap configuration
    config =
      element: document.getElementById("heatmapArea")
      radius: 10
      opacity: 50
      gradient:
        0: "rgb(234,242,246)"
        0.5: "rgb(78,158,196)"
        1: "rgb(198, 41, 16)"

    
    #creates and initializes the heatmap
    heatmap = h337.create(config)
    
    # let's get some data
    data =
      max: 20
      data: [
        {
          x: 10
          y: 25
          count: 5
        }
        {
          x: 50
          y: 25
          count: 20
        }
        {
          x: 80
          y: 25
          count: 10
        }
        {
          x: 100
          y: 25
          count: 10
        }
        {
          x: 120
          y: 25
          count: 20
        }
        {
          x: 200
          y: 25
          count: 5
        }
      ]

    
    # ...
    heatmap.store.setDataSet data
    return