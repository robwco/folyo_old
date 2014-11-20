# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.BudgetSelector = React.createClass

  displayName: 'BudgetSelector'

  getInitialState: -> position: 0

  updateState: (properties) -> @setState(Object.assign(@state, properties))

  setCurrentPosition: (position) -> @updateState(position: position)

  getPricingPoints: ->
    if @props.currentCategory && @props.currentProjectType
      category = @props.stats[@props.currentCategory]
      projectType = category.project_types[@props.currentProjectType]
      if projectType.coding_option
        if @props.currentOption
          projectType.pricing[@props.currentOption]
        else
          []
      else
        projectType.pricing
    else
      []

  componentDidMount: ->
    $selector = $(@getDOMNode())
    $slider = $('.slider-body', $selector)
    @updateState(width: $slider.width())

  render: ->
    <div className="budget-selector">
      <div className="budget-slider">
        <div className="slider-body heatmap-area">
          <Views.Budgets.Estimate.Legend {...@props}/>
          <Views.Budgets.Estimate.Heatmap {...@props} pricingPoints={@getPricingPoints()}/>
          <Views.Budgets.Estimate.Cursor {...@props}  pricingPoints={@getPricingPoints()}
            currentPosition={@state.position} sliderWidth={@state.width}
            setCurrentPosition={@setCurrentPosition}/>
        </div>
      </div>
    </div>
