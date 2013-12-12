#= require turbolinks
#= require map
#= require epiceditor
#= require s3_direct_upload

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

animationIn = 'fadeInUpBig'
animationOut= 'fadeOutUpBig'
animatedElement = -> if $(window.lastElementClicked).parents('.subnav').length > 0 then '#page-content' else '#page'
animateIn =  -> $(animatedElement()).toggleClass('animated', true).removeClass(animationOut).addClass(animationIn)
animateOut = ->
  $('section.footer').remove()
  $(animatedElement()).toggleClass('animated', true).removeClass(animationIn).addClass(animationOut)

head ->
  $ ->
    $(document).click (event) -> window.lastElementClicked = event.target

    page_load()

    $(document).on 'page:load', page_load
    $(document).on 'page:before-change', window.application_view.cleanup
    $(document).on 'page:change', animateIn
    $(document).on 'page:fetch', animateOut
    $(document).on 'page:restore', ->
      window.application_view.cleanup()
      animateIn()
      page_load()




