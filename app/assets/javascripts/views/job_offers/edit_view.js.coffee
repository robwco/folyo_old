window.Views.JobOffers ||= {}

class Views.JobOffers.EditView extends Views.ApplicationView

  interval = undefined
  lastFormState = undefined

  saveForm = ->
    $form = $('#edit_job_offer_form')
    if $form.serialize() != lastFormState
      lastFormState = $form.serialize()
      $.ajax
        url:        $form.attr('action')
        type:       'POST'
        data:       "#{lastFormState}&workflow_save=1"
        success: ->
          now = new Date()
          # getting time in this format 09:30 (filled with leading zeros)
          now_as_string = ('0' + now.getHours()).slice(-2) + ':' + ('0' + now.getMinutes()).slice(-2)
          $('.autosave-notice').hide().html("Autosaved at #{now_as_string}").fadeIn()

  render: ->
    super()
    # saving form every 30 secs (if changes have occured)
    lastFormState = $('form').serialize()
    interval = setInterval(saveForm, 30000)

    # showing coding notes only when value changes
    $('.coding-note').hide()
    $('input[name="job_offer[coding]"]').change ->
      if $(this).val() is "mandatory"
        $(".coding-note").fadeIn "fast"
      else
        $(".coding-note").fadeOut "fast"

  cleanup: ->
    super()
    clearInterval(interval)
    saveForm()
