window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  render: ->
    super()

jQuery ->
  $('.replies-view-list').click ->
    $('.replies').removeClass('replies-grid').addClass('replies-list').css("margin-left", "0px").css("margin-right", "0px")
  $('.replies-view-grid').click ->
    $('.replies').removeClass('replies-list').addClass('replies-grid')
    resizeDiv()

  resizeDiv = ->
    leftOffset = $(".main").offset().left
    $(".replies-grid").css("margin-left", "-" + leftOffset + "px").css("margin-right", "-" + leftOffset + "px")

  resizeDiv()
  $(window).resize resizeDiv