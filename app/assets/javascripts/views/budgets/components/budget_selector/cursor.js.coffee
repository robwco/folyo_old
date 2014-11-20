# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.Cursor = React.createClass

  displayName: 'Cursor'

  getPrice: ->
    price = @props.maxBudget * @props.currentPosition / @props.sliderWidth
    Math.round(price / 100) * 100

  getPosition: ->
    Math.round(@getPrice() * @props.sliderWidth / @props.maxBudget)

  getClosestPricingPoint: ->
    price = @getPrice()
    point = _.last(_.filter(@props.pricingPoints, (point) -> point.price <= price ))
    point || { percentile: 0, price: 0, count: 0 }

  componentDidMount: ->
    cursor = new Draggabilly(@getDOMNode(),
      axis: 'x'
      containment: true
      handle: '.cursor-body'
    )

    # updating state according to current position
    cursor.on 'dragMove', (instance, event, pointer) =>
      @props.setCurrentPosition(instance.position.x)

    # moving cursor to rounded price position
    cursor.on 'dragEnd', (instance, event, pointer) =>
      x = @getPosition()
      @props.setCurrentPosition(x)
      $(@getDOMNode()).css('left', "#{x}px")

  render: ->
    <div className="slider-cursor">

      <div className="cursor-tooltip cursor-price cursor-tooltip-up">
        <div className="inner">
          <div className="inner2">
            With a
            <span className="cursor-figure cursor-price-value">
              {" $#{@getPrice()} "}
            </span>
            budget…
          </div>
        </div>
      </div>

      <div className="cursor-body">
        <div className="cursor-left"/>
        <div className="cursor-center"/>
        <div className="cursor-right"/>
      </div>

      <div className="cursor-tooltip cursor-percent cursor-tooltip-down">
        <div className="inner">
          <div className="inner2">
            …you can reach
            <span className="cursor-figure cursor-percent-value">
            {" #{@getClosestPricingPoint().percentile}% "}
            </span>
            of designers.
          </div>
        </div>
      </div>

    </div>
