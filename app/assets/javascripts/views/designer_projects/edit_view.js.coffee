window.Views.DesignerProjects ||= {}

class Views.DesignerProjects.EditView extends Views.ApplicationView

  poller = undefined
  polling = false

  render: ->
    super()

    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()

    $('#s3-uploader').S3Uploader
      before_add: (file) ->
        if file.size > 2 * 1024 * 1024 # 2MB
          console.log("File is too big")
          false
        else
          true

    # this callback is called each time an upload is finished and S3 url is posted to server
    # only one poller is running even if multiple files are uploaded at the same time
    $('#s3-uploader').on 'ajax:success', (e, data) =>
      @start_polling(data.polling_path) unless polling

  cleanup: => @stop_polling()

  start_polling: (url) ->
    $('.artworks .spinner').removeClass('hidden')
    polling = true
    poller = setInterval(=>
      $.ajax
        url: url
        type: 'GET'
        dataType: 'JSON'
        success: (data) =>
          if data.complete
            @stop_polling()
            $artworks = $('.artworks')
            artworks_url = $artworks.attr('data-url')
            $.get artworks_url, (data) -> $artworks.html(data)
    , 1000)

  stop_polling: ->
    $('.artworks .spinner').addClass('hidden')
    clearInterval(poller) if poller?
    polling = false


