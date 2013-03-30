head ->

  $ ->

    # takes a shot ID and gets the image URL
    get_shot_url = (shot_id, success_callback, error_callback) ->
      jsonp_call "http://api.dribbble.com/shots/" + shot_id + "?callback=?", success_callback, error_callback

    # takes a player name and gets their last shot url
    get_last_shot_url = (player_name, success_callback, error_callback) ->
      jsonp_call "http://api.dribbble.com/players/" + player_name + "/shots?callback=?", success_callback, error_callback

    jsonp_call = (api_url, success_callback, error_callback) ->

      # http://code.google.com/p/jquery-jsonp/wiki/APIDocumentation
      # use $.jsonp instead of $.ajax because the error callback of $.ajax is not triggered by the 404
      $.jsonp
        url: api_url
        success: (data, textStatus) ->
          $(".loading").removeClass "loading"
          success_callback data

        error: ->
          $(".loading").removeClass "loading"
          error_callback()

    showError = (errorDiv) -> errorDiv.fadeIn("fast").removeClass "hidden"
    hideError = (errorDiv) -> errorDiv.fadeOut("fast").addClass "hidden"  unless errorDiv.hasClass("hidden")

    $(".limit-80").limit "80", ".chars-left"  if $(".limit-80").length

    $("#designer_featured_shot").change ->
      shot_id = $(this).val()
      parentLi = $(this).parent()
      unless shot_id is ""
        $errorDiv = $("#bad_shot")
        get_shot_url shot_id, ((data) ->
          $("#designer_featured_shot_url").val data.image_url
          hideError($errorDiv)
        ), -> showError($errorDiv)

      else
        # if designer removes their featured shot ID, replace the URL with the latest shot by default
        if player_name = $("#designer_dribble_username").val()
          get_last_shot_url player_name, (data) -> $("#designer_featured_shot_url").val data.shots[0].image_url

