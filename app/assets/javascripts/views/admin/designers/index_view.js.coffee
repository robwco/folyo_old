#= require ../../application_view

window.Views.Admin ||= {}
window.Views.Admin.Designers ||= {}

class Views.Admin.Designers.PendingView extends Views.ApplicationView

  show_checkmark: ($status_select) ->
    $status_select.parent().find(".checkmark").removeClass("hidden").fadeOut "slow"

  update_designer: (url, data, callback) ->
    data['_method'] = 'PATCH'
    $.ajax
      url:  url
      type: 'POST'
      dataType: 'json'
      data: data
      success: callback

  render: ->
    super()

    #$('html, body').animate({ scrollTop: $("#page-content").offset().top}, 300)

    $(".status-selector select").change (e) =>
      $status_select = $(e.target)
      designer_url = $status_select.attr("data-url")
      new_status = $status_select.val()
      if new_status == 'rejected'
        $status_select.siblings('.rejection-section').show()
      else
        @update_designer designer_url, { status: new_status }, =>
          @show_checkmark($status_select)

    $('.reject-btn').click (e) =>
      e.preventDefault()
      $btn = $(e.target)
      $status_select = $btn.parent().siblings('select')
      designer_url = $status_select.attr("data-url")
      rejection_message = $btn.siblings('.text').children('textarea').val()
      @update_designer designer_url, { status: 'rejected', rejection_message: rejection_message }, =>
        $btn.parent().hide()
        @show_checkmark($status_select)
