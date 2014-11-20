window.Views.Surveys ||= {}

class Views.Surveys.ShowView extends Views.ApplicationView

  render: ->
    $('.slider-cursor').each ->
      $selector = $(this).parents('.budget-selector')
      $answer = $(this).parents('.survey-answer')
      $sliderBody = $answer.find('.slider-body')

      # set initial value
      price = $answer.find('.slider-value').val()
      setPriceCursor(price, $sliderBody)
      setPriceValue(price, $answer)

      # make cursor draggable
      # xStep = Math.round($answer.find('.budget-slider').width()/100)
      cursor = new Draggabilly( this,
        axis: 'x'
        containment: true
        # grid: [ xStep, 0 ] * using a grid messes up the values
      )

      # on drag
      cursor.on 'dragMove', (instance, event, pointer) ->
        price = getPrice(instance.position.x)
        setPriceValue(price, $answer)

      cursor.on 'dragEnd', (instance, event, pointer) ->
        price = getPrice(instance.position.x)
        setPriceCursor(price, $sliderBody)

    # make cursor body clickable
    $('.slider-body').mousedown (e) ->
      $target = $(e.target)
      return if $target.parents('.slider-cursor').length > 0
      x = e.pageX - $target.offset().left
      price = getPrice(x)
      setPriceValue(price, $target.parents('.survey-answer'))
      setPriceCursor(price, $target)

setPriceValue = (price, $parent) ->
  price = roundPrice(price)
  $cursorPrice = $parent.find('.cursor-price-value')
  if price == 0
    if $cursorPrice.data('hasBeenDragged') == true
      text = "n/a"
    else
      text = "Drag Me!"
      $cursorPrice.data('hasBeenDragged', true)
  else
    text = '$'+price
  $cursorPrice.text(text)
  $parent.find('.slider-value').val(price)