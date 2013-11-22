window.Views.DesignerProjects ||= {}

class Views.DesignerProjects.EditView extends Views.ApplicationView

  poller = undefined
  polling = false
  $cropbox = undefined

  render: ->
    super()
    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()
    @enableFormBehavior()
    @enableUploader()
    @enableCropLink()

  enableFormBehavior: ->
    $('a.submit').click (e) ->
      e.preventDefault()
      $('#main-form').submit()
    $('#skills-form input').on 'change', (e) ->
      skill = $(e.target).val()
      checked = $(e.target).prop('checked')
      $("#main-form input[value='#{skill}']").prop('checked', checked)

  enableUploader: ->
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
      unless polling
        $('.upload-placeholder').html("<div class='upload-spinner-placeholder'><div class='spinner'/></div>")
        @start_polling(data.polling_path)

    if $('.spinner').length > 0
      @start_polling($('.spinner').attr('data-polling-path'))

  enableCropLink: ->
    $('a.crop').fancybox
      autoSize: false
      type: "inline"
      content: "<div id=\"cropbox-content\"></div>"
      beforeLoad: ->
        @width  = parseInt(@element.attr('data-width')) + 2
        @height = parseInt(@element.attr('data-height')) + 50
      beforeShow: =>
        $.ajax
          url: $("a.crop").attr('href')
          success: (data) =>
            $("#cropbox-content").html data
            @edit_crop()
          dataType: "html"

  start_polling: (url) ->
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
    $('.artworks .upload-spinner-placeholder').remove()
    clearInterval(poller) if poller?
    polling = false

  edit_crop: ->
    $cropbox = $('#cropbox')
    $cropbox.Jcrop
      onChange: @update_crop
      onSelect: @update_crop
      setSelect: [10, 10, 200, 150]
      aspectRatio: 4/3

  update_crop: (coords) ->
    ratio = $cropbox.attr('data-ratio');
    $("#crop_x").val(Math.round(coords.x * ratio))
    $("#crop_y").val(Math.round(coords.y * ratio))
    $("#crop_w").val(Math.round(coords.w * ratio))
    $("#crop_h").val(Math.round(coords.h * ratio))

  cleanup: => @stop_polling()


