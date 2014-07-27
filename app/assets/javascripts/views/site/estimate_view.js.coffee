window.Views.Site ||= {}

class Views.Site.EstimateView extends Views.ApplicationView

  render: ->

    @loadHeatMap()
    @makeDraggable()

  makeDraggable: ->
    elem = document.querySelector('#cursor');
    draggie = new Draggabilly( elem,
      axis: 'x'
      containment: '#slider'
      handle: '.cursor-body'
      # grid: [ 88, 0 ]
    )

    onDragMove = (instance, event, pointer) ->
      maxPrice = 10000 # get it from Rails, or fix it at 10000?
      xPos = instance.position.x
      totalWidth = $('#slider').width()
      amount = Math.round(maxPrice * xPos / totalWidth)
      if amount > maxPrice - 20 # round off at the end
        amount = maxPrice
      $('.cursor-amount-value').text('$'+amount)

    draggie.on( 'dragMove', onDragMove );

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