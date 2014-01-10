window.Views.Admin ||= {}
window.Views.Admin.JobOffers ||= {}

class Views.Admin.JobOffers.NewsletterSetupView extends Views.ApplicationView

  render: ->
    super()

    $(".mailchimp-text").focus ->
      $this = $(this)
      $this.select()

      # Work around Chrome little problem
      $this.mouseup ->

        # Prevent further mouseup intervention
        $this.unbind "mouseup"
        false
