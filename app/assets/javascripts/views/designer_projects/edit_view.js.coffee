window.Views.DesignerProjects ||= {}

class Views.DesignerProjects.EditView extends Views.ApplicationView

  render: ->
    super()

    Widgets.MarkdownEditor.enable()
    Widgets.LimitedText.enable()

    $('#s3-uploader').S3Uploader
      before_add: (file) ->
        if file.size > 2 * 1024 * 1024 # 2MB
          alert("File is too big")
          false
        else
          true

    $('#s3-uploader').on 'ajax:success', (e, data) ->
      console.log ("server was notified of new file on S3; responded with '#{data}")

