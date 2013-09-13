#= require turbolinks
#= require map
#= require wysiwyg
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

head ->
  $ ->

    page_load()

    document.addEventListener 'page:load', page_load
    document.addEventListener 'page:before-change', window.application_view.cleanup

