window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  update = (url, collapsed) ->
    $.ajax
      url: url
      type: 'POST'
      dataType: 'json'
      data:
        _method: 'PUT'
        collapsed: collapsed

  render: ->
    super()
    $(".collapse").click ->
      $link = $(this)
      li = $link.parent()
      url = $link.attr('data-url')

      if li.hasClass("collapsed")
        li.removeClass "collapsed"
        update(url, false)
      else
        $(this).parent().addClass "collapsed"
        update(url, true)

      false

