window.Widgets ||= {}

class Widgets.MarkdownEditor

  @enable: ->
    epiceditor_options = { button: { fullscreen: false }, clientSideStorage: false, autoGrow: true }

    $('.markdown > textarea').each (i, item) ->
      $(item).hide()
      $editor = $("<div class='epiceditor' id='#{item.id}_markdown'></div>").insertAfter(item)
      epiceditor_options.container = $editor.get(0)
      epiceditor_options.textarea = item
      epiceditor = new EpicEditor(epiceditor_options).load()
      $editor.data('epiceditor', epiceditor)
      if $(item).parent(".input").hasClass('error')
        $(epiceditor.getElement('editor').body).addClass('error')

    $('.markdown label').append("<a href='/markdown' tabindex='-1' title='Help for markdown syntax' class='markdown-logo fancybox fancybox.ajax'></a>")

    $('.inline-hints').each ->
      $hint = $(this)
      $input = $(this).parent().find("input, select")
      epiceditor = $(this).parent().find(".epiceditor").data('epiceditor')

      $input?.on 'focus change',->
        $(".inline-hints").removeClass('in-focus')
        $hint.addClass "in-focus"

      epiceditor?.on 'focus', ->
        $(".inline-hints").removeClass('in-focus')
        $hint.addClass "in-focus"

      $input?.on 'blur',     -> $(".inline-hints").removeClass('in-focus')
      epiceditor?.on 'blur', -> $(".inline-hints").removeClass('in-focus')