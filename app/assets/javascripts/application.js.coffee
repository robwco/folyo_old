#= require turbolinks
#= require jquery.turbolinks
#= require map
#= require wysiwyg
#= require epiceditor
#= require s3_direct_upload

#= require_self

head ->
  $ ->

    $('body').removeClass('no-js').addClass('js js-animate')

    if ($.browser.mozilla)
      $("body").removeClass("js-animate")

    epiceditor_options = { button: { fullscreen: false }, clientSideStorage: false, autoGrow: true }

    $(".markdown > textarea").each (i, item) ->
      $(item).hide()
      $editor = $("<div class='epiceditor' id='#{item.id}_markdown'></div>").insertAfter(item)
      epiceditor_options.container = $editor.get(0)
      epiceditor_options.textarea = item
      epiceditor = new EpicEditor(epiceditor_options).load()
      $editor.data('epiceditor', epiceditor)
      if $(item).parent(".input").hasClass('error')
        $(epiceditor.getElement('editor').body).addClass('error')

    $('.markdown label').append("<a href='/markdown' tabindex='-1' title='Help for markdown syntax' class='markdown-logo fancybox fancybox.ajax'></a>")


    $(".inline-hints").each ->
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

    $('#s3-uploader').S3Uploader()

    #$('#s3-uploader').on 's3_upload_failed', (e, content) ->
    #  console.log("#{content.filename} failed to upload")

    $(".mailchimp-text").focus ->
      $this = $(this)
      $this.select()

      # Work around Chrome little problem
      $this.mouseup ->

        # Prevent further mouseup intervention
        $this.unbind "mouseup"
        false


    $(".status-selector select").change ->
      status_select = $(this)
      designer_id = status_select.attr("name")
      new_status = status_select.val()
      $.update "/admin/designers/" + designer_id,
        status: new_status
      , ((response) ->
        status_select.parent().find(".checkmark").removeClass("hidden").fadeOut "slow"
      ), (response) ->
        console.log "error"
        console.log response.designer.status


    $(".collapse").click ->
      link = $(this)
      li = link.parent()
      url = document.URL
      designer_reply_id = link.attr("href").substring(1)
      url = url.substring(0, url.length - 1)  if url.charAt(url.length - 1) is "/"
      designer_reply_url = url + "/" + designer_reply_id
      if li.hasClass("collapsed")
        li.removeClass "collapsed"
        $.update designer_reply_url,
          collapsed: 0

      else
        $(this).parent().addClass "collapsed"
        $.update designer_reply_url,
          collapsed: 1

      false

    $(".message").each ->
      msg = $(this)
      p = $(this).find("p")
      msg.addClass "long"  if p.text().length > 230

    $(".limited").on "focus", ->
      $(this).trigger('keyup') # refresh current character count
      $(this).siblings(".character-counter-main-wrapper").fadeIn("fast")

    $(".limited").on "blur",  -> $(this).siblings(".character-counter-main-wrapper").fadeOut("fast")

    $('.limited').each  ->
      limit_size_class = $(this).attr('class').split(' ').filter((i) -> i.match(/limited-\d+/)?)[0]
      if limit_size_class?
        limit_size = parseInt(limit_size_class.match(/limited-(\d+)/)[1], 10)
        if ($editor = $(this).siblings('.epiceditor')).length > 0
          $editor.css(height: "#{limit_size/2}px")
          $editor.data('epiceditor').reflow('height')

        $(this).characterCounter(
          maximumCharacters: limit_size
          characterCounterNeeded: false
        )

    $(".coding-note").hide()
    $("input[name=\"job_offer[coding]\"]").change ->
      if $(this).val() is "mandatory"
        $(".coding-note").fadeIn "fast"
      else
        $(".coding-note").fadeOut "fast"

    $(".lightbox").fancybox maxWidth: 400
    $(".fancybox").each ->
      link = $(this).attr("href") + ".js"
      $(this).fancybox
        width: 400
        autoSize: false
        height: 170
        type: "inline"
        content: "<div id=\"lightbox-content\"></div>"
        beforeShow: ->
          $.ajax
            url: link
            success: (data) ->
              $("#lightbox-content").html data
            dataType: "html"

    # $('body').removeClass('fixed-header')
    # $(window).off 'scroll'

    # if $('body').hasClass('offer-client')
    #   $(window).on 'scroll', ->
    #     scroll = $("body").scrollTop()
    #     if scroll > 80
    #       $('body').addClass('fixed-header')
    #     if scroll < 40 # when the fixed header is activated, the whole page jumps up by 40px. so we need to take the difference into account
    #       $('body').removeClass('fixed-header')

    $(".waypoint").waypoint ((direction) ->
      $(this).addClass "animate"
    ),
    offset: "60%"

    $.localScroll()