#= require turbolinks
#= require jquery.turbolinks
#= require misc/parseURI.js
#= require jquery-iframe-content
#= require map
#= require wysiwyg
#= require epiceditor

#= require_self

head ->
  $ ->
    $.extend
      getUrlVars: ->
        vars = []
        hash = undefined
        hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
        i = 0

        while i < hashes.length
          hash = hashes[i].split("=")
          vars.push hash[0]
          vars[hash[0]] = hash[1]
          i++
        vars

      getUrlVar: (name) ->
        $.getUrlVars()[name]

    $.ajaxSetup beforeSend: (xhr) ->
      xhr.setRequestHeader "Accept", "text/javascript"

    $(".tooltip, .wysiwyg .toolbar li").not(".separator").qtip position:
      my: "bottom center" # Position my bottom center...
      at: "top center" # at the bottom right of...
      target: false # my target
      adjust:
        y: -8

    $(".bottom-tip").qtip position:
      my: "top center" # Position my bottom center...
      at: "bottom center" # at the bottom right of...
      target: false # my target
      adjust:
        y: 8

    epiceditor_options = { button: { fullscreen: false }, clientSideStorage: false }

    $(".markdown").each (i, item) ->
      $(item).hide()
      $editor = $("<div class='epiceditor' id='#{item.id}_markdown'></div>").insertAfter(item)
      epiceditor_options.container = $editor.get(0)
      epiceditor_options.textarea = item
      epiceditor = new EpicEditor(epiceditor_options).load()
      $editor.data('epiceditor', epiceditor)
      if $(item).parent(".input").hasClass('error')
        $(epiceditor.getElement('editor').body).addClass('error')


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

    $("#designer_reply_message").autoGrow()
    $(".limit").one "keydown", ->
      $(".remaining").fadeIn "fast"

    $(".coding-note").hide()
    $("input[name=\"job_offer[coding]\"]").change ->
      if $(this).val() is "3"
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


    $(".thread-link").click ->
      $(this).parents(".client").find(".threads").toggleClass "hidden"
      false

    if $('body').hasClass('offer-client')
      $(window).scroll ->
        scroll = $("body").scrollTop();
        if scroll > 80
          $('body').addClass('fixed-header')
        else
          $('body').removeClass('fixed-header')
