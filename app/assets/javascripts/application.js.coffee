#= require turbolinks
#= require map
#= require epiceditor
#= require s3_direct_upload
#= require spin

#= require_tree ./widgets
#= require_tree ./views

#= require_self

page_load = ->
  class_name = $('body').attr('data-class-name')
  window.application_view = try
    eval("new #{class_name}()")
  catch error
    console.log "No view class found for #{class_name}, defaulting to ApplicationView."
    new Views.ApplicationView()
  window.application_view.render()

spinner = new Spinner(radius: 42, length: 1, lines: 24, color: '#FFF')

animatedElement = -> if $(window.lastElementClicked).parents('.subnav').length > 0 then '#page-content' else '#page'
animateIn =  ->
  $(animatedElement()).addClass('animated').removeClass('fadeOut').addClass('fadeIn')
  spinner.stop()
animateOut = ->
  $clickedItem = $(window.lastElementClicked)
  $('a', $clickedItem.parents('ul')).removeClass('current')
  $clickedItem.addClass('current')
  $('h1.title').html($clickedItem.attr('title')) if $clickedItem.attr('title')
  $('section.footer').remove()
  $(animatedElement()).addClass('animated').removeClass('fadeIn').addClass('fadeOut')
  spinner.spin($('.logo')[0])

head ->
  $ ->
    $(document).click (event) -> window.lastElementClicked = event.target

    page_load()

    $(document).on 'page:load', page_load
    $(document).on 'page:before-change', ->
      window.application_view.cleanup()
      true
    $(document).on 'page:change', animateIn
    $(document).on 'page:fetch', animateOut
    $(document).on 'page:restore', ->
      window.application_view.cleanup()
      animateIn()
      page_load()




