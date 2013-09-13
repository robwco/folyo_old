#= require ../../application_view

window.Views.Admin ||= {}
window.Views.Admin.Designers ||= {}

class Views.Admin.Designers.IndexView extends Views.ApplicationView

  render: ->
    super()

    $(".status-selector select").change ->
      $status_select = $(this)
      designer_url = $status_select.attr("data-url")
      new_status = $status_select.val()
      $.ajax
        url:  designer_url
        type: 'POST'
        dataType: 'json'
        data:
          _method: 'PUT'
          status: new_status
        success: ->
          $status_select.parent().find(".checkmark").removeClass("hidden").fadeOut "slow"
