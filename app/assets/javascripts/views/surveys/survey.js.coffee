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
      cursor = new Draggabilly( this,
        axis: 'x'
        containment: true
        handle: '.cursor-body'
        grid: [ $answer.find('.budget-slider').width()/100, 0 ]
      )

      # on drag
      cursor.on 'dragMove', (instance, event, pointer) ->
        price = getPrice(instance.position.x)
        setPriceValue(price, $answer)

      cursor.on 'dragEnd', (instance, event, pointer) ->
        price = getPrice(instance.position.x)
        setPriceCursor(price, $sliderBody)

    $('.slider-body').mousedown (e) ->
      $target = $(e.target)
      return if $target.parents('.slider-cursor').length > 0
      x = e.pageX - $target.offset().left
      price = getPrice(x)
      setPriceValue(price, $target.parents('.survey-answer'))
      setPriceCursor(price, $target)

  setPriceValue = (price, $parent) ->
    price = roundPrice(price)
    $parent.find('.cursor-price-value').text('$'+price)
    $parent.find('.slider-value').val(price)

  setPriceCursor = (price, $parent) ->
    price = roundPrice(price)
    x = getCoordinatesByPrice(price, $parent)
    $('.slider-cursor', $parent).css('left', x)

  roundPrice = (price) -> price = Math.round(price/100) * 100

  getCoordinatesByPrice = (price, $slider) -> price / maxPrice * $slider.width()

