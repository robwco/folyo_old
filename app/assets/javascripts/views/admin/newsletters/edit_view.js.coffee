window.Views.Admin ||= {}
window.Views.Admin.Newsletters ||= {}

class Views.Admin.Newsletters.EditView extends Views.ApplicationView

  render: ->
    super()
    $('a.preview').click (e) ->
      e.preventDefault()
      url = $(e.target).attr('href')
      window.open(url, '_blank', 'width=800,height=800,left=400,top=100')

  cleanup: ->
    super()





