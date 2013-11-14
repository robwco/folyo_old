window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  render: ->
    super()

    $(".reply").click (e) =>
      e.preventDefault()

      $li = $(e.currentTarget)
      url = $li.attr('data-url')

      if $li.hasClass("collapsed")
        $li.removeClass("collapsed").addClass("expanded")
        # @update(url, false)
      else
        $li.addClass("collapsed").removeClass("expanded")
        # @update(url, true)

  update: (url, collapsed) ->
    $.ajax
      url: url
      type: 'POST'
      dataType: 'json'
      data:
        _method: 'PUT'
        collapsed: collapsed

