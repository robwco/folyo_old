window.Views.Site ||= {}

class Views.Site.HomeView extends Views.ApplicationView

  render: ->
    $(".waypoint").waypoint ((direction) ->
      $(this).addClass "animate"
    ),
    offset: "60%"

    $.localScroll()