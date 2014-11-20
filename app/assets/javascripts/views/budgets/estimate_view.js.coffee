# VOCABULARY
# cursor: the center part that you drag that contains the labels
# slider: the part on which you drag it that contains the legend
# selector: the whole widget

# TODO
# - include draggability js properly (use bower?)
# - replace heatmap.js by a bunch of divs of various sizes
# - generate "heatmap" from data contained in projects object
# - regenerate "heatmap" on project type change
# - add sample project (use something for JS templates, or else just hardcode the HTML)
# - make whole thing responsive
# - enable clicking anywhere on the heatmap
# - make price and percent parts draggable as well

window.Views.Budgets ||= {}

# note: maybe find a way to share the projects JSON object between skills, survey, and here? Otherwise just hard-code it.
@projects = if $('.budget-form').length > 0
  JSON.parse($('.budget-form').attr('data-statistics'))
else
  {}

getCategory = (categoryName) ->
  return _.findWhere(projects, {name: categoryName})

getProject = (categoryName, projectName) ->
  return project = _.findWhere(getCategory(categoryName).project_types, {name: projectName})

# given an array, populate list with HTML elements (radio buttons)
populateList = (selectElement, myArray) ->
  # first, clear everything
  selectElement.find("*").remove()
  $.each(myArray, ->
    # use either "name" property, or array item itself
    optionValue = (if !!@name then @name else this)
    selectElement.append($('<label><input type="radio" name="'+selectElement.attr('class')+'" value="'+optionValue+'"/><span>'+optionValue+'</span></label>'))
  )

@maxPrice = 20000 # get it from Rails, or fix it at 10000?

# temporary array just to populate the heatmap while developing
pricesArray = [392, 748, 748, 1036, 1265, 1265, 1419, 1763, 1786, 1847, 1895, 1895, 1895, 2362, 2447, 3235, 3235, 3927, 4030, 4703, 4822]

# given a price, get its position on the slider
@getPosition = (price) ->
  return Math.round(price * $('.budget-slider').width() / maxPrice)

# given a coordinate on the slider, get the corresponding price
@getPrice = (xcoord) ->
  return Math.round(maxPrice * xcoord / $('.budget-slider').width())

# given a number, get the closest price that exists in the price array
getClosestPrice = (price) ->
  closestPrice = pricesArray[0]
  pricesArray.forEach((value, index) ->
    if (Math.abs(value - price) < Math.abs(closestPrice - price))
      closestPrice = value;
  )
  return closestPrice

# round a price
@roundPrice = (price) ->
  roundByHowMuch = 100
  return Math.round(price/roundByHowMuch) * roundByHowMuch

# given a price, get the coordinates
@getCoordinatesByPrice = (price, $selector) -> price / maxPrice * $('.slider-body').width()

# given a coordinate, return closest coordinate corresponding to a rounded price
@roundCoordinate = (xcoord) ->
  @getCoordinatesByPrice(@roundPrice(@getPrice(xcoord)))

# mock function to simulate getting the percentile for a given price
@getPercent = (price) ->
  position = pricesArray.indexOf(getClosestPrice(price))
  return Math.round(position * 100 / pricesArray.length)

# transform array of numbers into JSON object accepted by heatmap.js
# note: we probably want to generate the JSON object in Ruby instead and include it in "projects"
pricesData = pricesArray.map((price, index, myArray) ->
  return {
    x:getPosition(price),
    y:25,
    count:1
  }
)

updateHeatmap = (category, type, option) ->
  project = getProject(category, type)
  data = project.pricing || []
  totalPoints = 100
  [1..(totalPoints-1)].forEach( (i) ->
    point = _.findWhere(data, {price: i * totalPoints})
    if(!!point)
      diameter = point.count * 3
    else
      diameter = 0
    dot = window.heatmap.select("circle:nth-of-type("+i+")").animate({r: diameter}, 300)
  )

@setPriceCursor = (price, $slider) ->
  price = roundPrice(price)
  x = getCoordinatesByPrice(price, $slider)
  $('.slider-cursor', $slider).css('left', x)

@setCursorPosition = ($cursor, xcoord) ->
  $cursor.css('left', xcoord)

updateCursor = ($cursor, xcoord) -> # take a cursor and an x coordinate, and update the cursor's labels
  $selector = $cursor.parents('.budget-selector')
  price = roundPrice(getPrice(xcoord))
  if price > maxPrice - 20 # round off at the end
    price = maxPrice
  $('.cursor-price-value').text('$'+price)
  $('.cursor-percent-value').text(getPercent(price)+"%")

  # constrain tooltip bodies
  $('.cursor-tooltip .inner').each( ->
    offset = 0

    cursorLeftEdge = $(this).offset().left
    cursorRightEdge = cursorLeftEdge + $(this).width()
    selectorLeftEdge = $selector.offset().left
    selectorRightEdge = selectorLeftEdge + $selector.width()

    leftDelta = Math.round(cursorLeftEdge - selectorLeftEdge)
    rightDelta = Math.round(selectorRightEdge - cursorRightEdge)

    # console.log('distance from left edge: '+leftDelta)
    # console.log('distance from right edge: '+rightDelta)

    if(leftDelta < 0)
      offset = -leftDelta

    if(rightDelta < 0)
      offset = rightDelta

    $(this).find('.inner2').css('left', offset + 'px')
  )

class Views.Budgets.EstimateView extends Views.ApplicationView

  render: ->

    @settingsSetup()
    @loadHeatMap()
    @makeDraggable()
    @makeClickable()

  
  makeDraggable: ->
    $('.slider-cursor').each( ->
      elem = this
      $selector = $(this).parents('.budget-selector')

      # make cursor draggable
      cursor = new Draggabilly( elem,
        axis: 'x'
        containment: true
        handle: '.cursor-body'
        # grid: [ 88, 0 ]
      )

      # on drag
      cursor.on 'dragMove', (instance, event, pointer) ->
        updateCursor($(instance.element), instance.position.x)
      

      # cursor.on 'dragMove', (instance, event, pointer) ->
      #   price = getPrice(instance.position.x)
      #   setPriceValue(price, $answer)

      cursor.on 'dragEnd', (instance, event, pointer) -> # make cursor "stick" to each step
        xcoord = roundCoordinate(instance.position.x)
        setCursorPosition($(instance.element), xcoord)
    )

  # make cursor body clickable
  makeClickable: ->
    $('.slider-body').mouseup (e) ->
      $target = $(e.target)
      $slider = $target.parents('.slider-body')
      $cursor = $('.slider-cursor', $slider)
      return if $target.parents('.slider-cursor').length > 0 # I don't remember what this does?
      xcoord = e.pageX - $target.offset().left
      updateCursor($cursor, xcoord)
      setCursorPosition($cursor, xcoord)

  loadHeatMap: ->
    window.heatmap = Snap(".slider-heatmap")
    totalPoints = 100
    [1..(totalPoints-1)].forEach( (i) ->
      xCoord = i * $('.slider-heatmap').width() / totalPoints
      dot = window.heatmap.circle(xCoord, 25, 0)
      dot.attr({
        fill: "#86d259",
      })
    )

  settingsSetup: ->

    # 3 main settings blocks
    categoryBlock = $('.project-category')
    typeBlock = $('.project-type')
    optionsBlock = $('.project-options')

    # set up dynamic grid
    containerWidth = $('.budget-project').width()
    blockWidth = categoryBlock.width()
    # use relative offsets using three-columns position as 0 origin
    oneOfOne = blockWidth+20
    oneOfTwo = ((containerWidth - (2 * blockWidth) - 20)/2)
    twoOfTwo = oneOfTwo
    categoryBlock.css('left', oneOfOne+'px')
    typeBlock.css('left', twoOfTwo+'px')
    optionsBlock.css('left', '0px')

    # parent div of radio buttons
    categorySelect = $('.project-select-category')
    typeSelect = $('.project-select-type')
    optionsSelect = $('.project-select-options')

    # when design category changes
    # seems like the change event works on divs too?
    categorySelect.change( ->
      # get the project types corresponding to the current category
      selectedProjectTypes = getCategory(categorySelect.find(':checked').val()).project_types
      # populate the project types list
      populateList(typeSelect, selectedProjectTypes)
      # show the project type block
      categoryBlock.css('left', oneOfTwo+'px')
      typeBlock.css('left', twoOfTwo+'px')
      typeBlock.css('opacity', 1)
      # since we haven't picked a project type yet, hide the options blocks for now
      optionsBlock.css('opacity', 0)
    )

    # when project type changes
    typeSelect.change( ->
      currentCategory = categorySelect.find(':checked').val()
      currentType = typeSelect.find(':checked').val()
      selectedOptions = getProject(currentCategory, currentType).options || []
      # only populate show the options block if there actually are options
      if !!selectedOptions.length
        populateList(optionsSelect, selectedOptions)
        categoryBlock.css('left', '0px')
        typeBlock.css('left', '0px')
        optionsBlock.css('opacity', 1)
      else
        # if there are no options, update heatmap right away
        updateHeatmap(currentCategory,currentType)
    )

    optionsSelect.change( ->
      currentCategory = categorySelect.find(':checked').val()
      currentType = typeSelect.find(':checked').val()
      currentOptions = optionsSelect.find(':checked').val()
      updateHeatmap(currentCategory, currentType, currentOptions)
    )