window.Views.Designers ||= {}

class Views.Designers.BudgetsView extends Views.ApplicationView

  render: ->
    super()
    $('.skill-checkbox').on 'change', (e) ->
      $checkbox = $(e.target)
      $checkbox.parents('.skill').children('.subskill').toggle($checkbox.prop('checked'))

  cleanup: ->
    super()
