# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.Legend = React.createClass

  displayName: 'Legend'

  getDefaultProps: ->
    sliceCount: 10

  budgetSlices: ->
    for i in [1..@props.sliceCount]
      (@props.maxBudget / (@props.sliceCount * 1000)) * i

  render: ->
    createSlice = (slice) -> <li key={"legend-slice-#{slice}"}>{"$#{slice}k"}</li>

    <div className="slider-legend slider-prices">
      <li>$0</li>
      { @budgetSlices().map(createSlice) }
    </div>
