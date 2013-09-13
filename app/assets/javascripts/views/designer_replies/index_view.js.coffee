window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  render: ->
    super()

    $(".collapse").click (e) =>
      e.preventDefault()

      $li = $(e.target).parents('li')
      url = $li.attr('data-url')

      if $li.hasClass("collapsed")
        $li.removeClass "collapsed"
        @update(url, false)
      else
        $li.addClass "collapsed"
        @update(url, true)

  update: (url, collapsed) ->
    $.ajax
      url: url
      type: 'POST'
      dataType: 'json'
      data:
        _method: 'PUT'
        collapsed: collapsed

