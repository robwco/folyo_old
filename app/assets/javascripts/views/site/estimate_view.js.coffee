# TODO
# - include draggability js properly (use bower?)
# - replace heatmap.js by a bunch of divs of various sizes
# - generate "heatmap" from data contained in projects object
# - regenerate "heatmap" on project type change
# - add sample project (use something for JS templates, or else just hardcode the HTML)
# - improve animation of "pick a project" section
# - make whole thing responsive

window.Views.Site ||= {}

# note: maybe find a way to share the projects JSON object between skills, survey, and here? Otherwise just hard-code it.
@projects = [
  {
    name: 'Logo & Identity Design'
    project_types: [
      {
        name: 'Logo Design'
        sample_project: {
          project_name: 'CoreFx Logo',
          author_name: 'Julien Renvoye',
          author_url: 'https://dribbble.com/JulienRenvoye',
          project_image: 'budgets/logo1.jpg',
          project_description: 'A clean, modern logo for a tech company. Included a short research phase, a few sketches, and a couple practical applications (business cards).',
          project_url: 'https://dribbble.com/shots/1569977-CoreFx-logo-design-process/attachments/241258'
        }
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

# get the list of project types for a project category
getProjectTypes = (categoryName) ->
  category = $.grep(projects, (category) -> 
    return category.name == categoryName
  )
  return category[0].project_types

# get the list of options given a category and a project
getProjectOptions = (categoryName, projectName) ->
  projectsTypes = getProjectTypes(categoryName)
  project = $.grep(projectsTypes, (project) -> 
    return project.name == projectName
  )
  # if there are no options, return an empty array
  return (if project[0].options then project[0].options else[])

# given an array, populate list with HTML elements (radio buttons)
populateList = (selectElement, myArray) ->
  # first, clear everything
  selectElement.find("*").remove()
  $.each(myArray, ->
    # use either "name" property, or array item itself
    optionValue = (if !!@name then @name else this)
    selectElement.append($('<label><input type="radio" name="'+selectElement.attr('class')+'" value="'+optionValue+'"/><span>'+optionValue+'</span></label>'))
  )

@maxPrice = 10000 # get it from Rails, or fix it at 10000?

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

class Views.Site.EstimateView extends Views.ApplicationView

  render: ->

    @loadProjects()
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
    # heatmap configuration
    config =
      element: document.getElementById("heatmapArea")
      radius: 10
      opacity: 50
      gradient:
        0: "rgb(234,242,246)"
        0.5: "rgb(78,158,196)"
        1: "rgb(255, 255, 255)"

    
    #creates and initializes the heatmap
    heatmap = h337.create(config)
    
    data =
      max: 1
      data: pricesData

    heatmap.store.setDataSet data
    return

  loadProjects: ->

    # 3 main settings blocks
    categoryBlock = $('.project-category')
    typeBlock = $('.project-type')
    optionsBlock = $('.project-options')

    # parent div of radio buttons
    categorySelect = $('.project-select-category')
    typeSelect = $('.project-select-type')
    optionsSelect = $('.project-select-options')

    # when design category changes
    # seems like the change event works on divs too?
    categorySelect.change( ->
      # get the project types corresponding to the current category
      selectedProjectTypes = getProjectTypes(categorySelect.find(':checked').val())
      # populate the project types list
      populateList(typeSelect, selectedProjectTypes)
      # show the project type block
      typeBlock.fadeIn('fast')
      # since we haven't picked a project type yet, hide the options blocks for now
      optionsBlock.fadeOut('fast')
    )

    # when project type changes
    typeSelect.change( ->
      selectedOptions = getProjectOptions(categorySelect.find(':checked').val(), typeSelect.find(':checked').val())
      # only populate show the options block if there actually are options
      if !!selectedOptions.length
        populateList(optionsSelect, selectedOptions)
        optionsBlock.fadeIn('fast')        
    )