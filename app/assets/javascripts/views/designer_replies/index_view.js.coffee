window.Views.DesignerReplies ||= {}

replyView = 'list'

switchList = ->
  replyView = 'list'
  $('.replies-view a').removeClass('active')
  $('.replies-view-list').addClass('active')
  $('.replies').removeClass('replies-grid').addClass('replies-list').css("margin-left", "0px").css("margin-right", "0px")

switchGrid = ->
  replyView = 'grid'
  $('.replies-view a').removeClass('active')
  $('.replies-view-grid').addClass('active')
  $('.replies').removeClass('replies-list').addClass('replies-grid')
  resizeDiv()

resizeDiv = ->
  leftOffset = $(".main").offset().left
  $(".replies-grid").css("margin-left", "-" + leftOffset + "px").css("margin-right", "-" + leftOffset + "px")

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  render: ->
    super()

    if replyView == 'grid'
      switchGrid()

    $('.replies-view-list').click ->
      switchList()

    $('.replies-view-grid').click ->
      switchGrid()

    resizeDiv()
    $(window).resize resizeDiv


