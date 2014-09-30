# TODO
# - include draggability js properly (use bower?)
# - replace heatmap.js by a bunch of divs of various sizes
# - generate "heatmap" from data contained in projects object
# - regenerate "heatmap" on project type change
# - add sample project (use something for JS templates, or else just hardcode the HTML)
# - make whole thing responsive
# - enable clicking anywhere on the heatmap
# - make price and percent parts draggable as well

window.Views.Site ||= {}

# note: maybe find a way to share the projects JSON object between skills, survey, and here? Otherwise just hard-code it.
@projects = [
  {
    name: 'Logo & Identity Design'
    project_types: [
      {
        name: 'Logo Design'
        sample_project:
          project_name: 'CoreFx Logo'
          author_name: 'Julien Renvoye'
          author_url: 'https://dribbble.com/JulienRenvoye'
          project_image: 'budgets/logo1.jpg'
          project_description: 'A clean, modern logo for a tech company. Included a short research phase, a few sketches, and a couple practical applications (business cards).'
          project_url: 'https://dribbble.com/shots/1569977-CoreFx-logo-design-process/attachments/241258'
        pricing_data: [
          {
            price: 300
            percentile: 3
            count: 2
          },
          {
            price: 400
            percentile: 5
            count: 4
          },
          {
            price: 500
            percentile: 10
            count: 3
          },
          {
            price: 700
            percentile: 11
            count: 2
          }
        ]
      },
      {
        name: 'Full Identity Design'
        sample_project: {
          project_name: 'Gbox Studios',
          author_name: 'Bratus',
          author_url: 'http://bratus.co/',
          project_image: 'budgets/gbox.jpg',
          project_description: 'A full identity for a video production company, including a logo, icons, and packaging.',
          project_url: 'https://www.behance.net/gallery/18065083/Gbox-Studios-Brand-identity-'
        }
      }
    ]
  },
  {
    name: 'Web Design'
    project_types: [
      {
        name: 'Coming Soon Page'
        options: ['No Coding', 'HTML/CSS Coding']
        sample_project: {
          project_name: 'Snow Hippos',
          author_name: 'Martin Halik',
          author_url: 'http://martinhalik.cz/',
          project_image: 'budgets/snowhippos.jpg',
          project_description: 'A simple “coming soon” page with a few elements.',
          project_url: 'https://dribbble.com/shots/769460-Dont-be-lame-be-a-snow-hippo/attachments/191157'
        }
        pricing_data: [
          {
            price: 700
            percentile: 3
            count: 2
          },
          {
            price: 800
            percentile: 5
            count: 4
          },
          {
            price: 1000
            percentile: 10
            count: 3
          },
          {
            price: 1200
            percentile: 11
            count: 2
          },
          {
            price: 2600
            percentile: 56
            count: 3
          }
        ]
        pricing_data_with_coding: [
          {
            price: 1000
            percentile: 3
            count: 2
          },
          {
            price: 1100
            percentile: 5
            count: 4
          },
          {
            price: 1300
            percentile: 10
            count: 3
          },
          {
            price: 1500
            percentile: 11
            count: 2
          }
        ]
      },
      {
        name: 'Landing Page'
        options: ['No Coding', 'HTML/CSS Coding']
        sample_project: {
          project_name: 'Landing Page',
          author_name: 'Haraldur Thorleifsson',
          author_url: 'http://haraldurthorleifsson.com/',
          project_image: 'budgets/landingpage.jpg',
          project_description: 'A landing page introducing a product with an illustration, features, and explanatory copy.',
          project_url: 'https://dribbble.com/shots/934145-Landing-page-design/attachments/104293'
        }
      }
    ]
  }
]

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

# given a position on the slider, get the corresponding price
@getPrice = (position) ->
  return Math.round(maxPrice * position / $('.budget-slider').width())

# given a number, get the closest price that exists in the price array
getClosestPrice = (price) ->
  closestPrice = pricesArray[0]
  pricesArray.forEach((value, index) ->
    if (Math.abs(value - price) < Math.abs(closestPrice - price))
      closestPrice = value;
  )
  return closestPrice

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
  data = project.pricing_data || []
  totalPoints = 100
  [1..(totalPoints-1)].forEach( (i) ->
    point = _.findWhere(data, {price: i * totalPoints})
    if(!!point)
      diameter = point.count * 3
    else
      diameter = 0
    dot = window.heatmap.select("circle:nth-of-type("+i+")").animate({r: diameter}, 300)
  )

class Views.Site.EstimateView extends Views.ApplicationView

  render: ->

    @settingsSetup()
    @loadHeatMap()
    @makeDraggable()

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
      cursor.on( 'dragMove', (instance, event, pointer) ->
        price = getPrice(instance.position.x)
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
      )
    )

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