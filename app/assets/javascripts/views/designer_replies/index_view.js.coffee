window.Views.DesignerReplies ||= {}

class Views.DesignerReplies.IndexView extends Views.ApplicationView

  render: ->
    super()

jQuery ->
  $('.replies-view-list').click ->
    $('.replies').removeClass('replies-grid').addClass('replies-list')
  $('.replies-view-grid').click ->
    $('.replies').removeClass('replies-list').addClass('replies-grid')
