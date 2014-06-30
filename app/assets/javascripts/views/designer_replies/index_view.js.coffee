window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  rememberView = (view) ->
    $.cookie('folyo_reply_view', view, { expires: 365, path: '/' })

  switchList = ->
    rememberView('list')
    $('.replies-view a').removeClass('active')
    $('.replies-view-list').addClass('active')
    $('.replies').removeClass('replies-grid').addClass('replies-list').css("margin-left", "0px").css("margin-right", "0px")

  switchGrid = ->
    rememberView('grid')
    $('.replies-view a').removeClass('active')
    $('.replies-view-grid').addClass('active')
    $('.replies').removeClass('replies-list').addClass('replies-grid')
    resizeDiv()

  resizeDiv = ->
    leftOffset = $(".main").offset().left
    $(".replies-grid").css("margin-left", "-" + leftOffset + "px").css("margin-right", "-" + leftOffset + "px")

  render: ->
    super()

    if $.cookie('folyo_reply_view') == 'grid'
      switchGrid()

    $('.replies-view-list').click ->
      switchList()

    $('.replies-view-grid').click ->
      switchGrid()

    resizeDiv()
    $(window).resize resizeDiv
