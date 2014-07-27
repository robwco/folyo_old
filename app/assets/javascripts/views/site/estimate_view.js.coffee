window.Views.Site ||= {}

maxPrice = 10000 # get it from Rails, or fix it at 10000?
totalWidth = $('#slider').width()

pricesArray = [392, 748, 990, 1036, 1265, 1295, 1419, 1763, 1786, 1847, 1895, 2013, 2018, 2362, 2447, 3235, 3439, 3927, 4030, 4703, 4822]

getPosition = (price) ->  
  return Math.round(price * totalWidth / maxPrice)

getPrice = (position) ->
  return Math.round(maxPrice * position / totalWidth)

getClosestPrice = (price) -> # not real
  closestPrice = pricesArray[0]
  pricesArray.forEach((value, index) ->
    if (Math.abs(value - price) < Math.abs(closestPrice - price))
      closestPrice = value;
  )
  return closestPrice

getPercent = (price) -> # not real
  position = pricesArray.indexOf(getClosestPrice(price))
  return Math.round(position * 100 / pricesArray.length)

pricesData = pricesArray.map((price) ->
  return {
    x:getPosition(price),
    y:25,
    count:1
  }
)
# note: we probably want to generate the JSON object in Ruby, actually

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
      price = getPrice(instance.position.x)
      if price > maxPrice - 20 # round off at the end
        price = maxPrice
      $('.cursor-price-value').text('$'+price)
      $('.cursor-percent-value').text(getPercent(price)+"%")

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
      max: 1
      data: pricesData

    
    # ...
    heatmap.store.setDataSet data
    return


