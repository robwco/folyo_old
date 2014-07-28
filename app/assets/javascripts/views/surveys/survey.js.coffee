window.Views.Surveys ||= {}

class Views.Surveys.ShowView extends Views.ApplicationView

  render: ->
    @makeDraggable()


  sliderChange: ->
    $('.budget-slider').change( ->
      console.log(this.value)
      $(this).parents('.survey-answer').find('.slider-value input').val(this.value)
    )
  makeDraggable: ->
    $('.slider-cursor').each( ->
      elem = this
      $answer = $(elem).parents('.survey-answer')
      # make cursor draggable
      cursor = new Draggabilly( elem,
        axis: 'x'
        containment: true
        handle: '.cursor-body'
        grid: [ $answer.find('.budget-slider').width()/100, 0 ]
      )

      # on drag
      cursor.on( 'dragMove', (instance, event, pointer) ->
        price = getPrice(instance.position.x)
        if price > maxPrice - 20 # round off at the end
          price = maxPrice
        $answer.find('.cursor-price-value').text('$'+price)
        $answer.find('.slider-value').val(price)
      )
    )