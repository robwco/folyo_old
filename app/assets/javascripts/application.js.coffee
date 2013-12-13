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

spinner = new Spinner(radius: 42, length: 1, lines: 24, color: '#DADADA')

animatedElement = ->
  if $(window.lastElementClicked).parents('.subnav').length > 0
    if $(window.lastElementClicked).parents('.sidebar').length > 0
      '#page-content .container .main'
    else
      '#page-content'
  else
    '#page'

animateIn =  ->
  $(animatedElement()).show()
  spinner.stop()

animateOut = ->
  $clickedItem = $(window.lastElementClicked)
  $('a', $clickedItem.parents('ul')).removeClass('current')
  $clickedItem.addClass('current')
  $('body').css('height', $('body').height())
  $('section.footer').hide()
  $(animatedElement()).hide()
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

