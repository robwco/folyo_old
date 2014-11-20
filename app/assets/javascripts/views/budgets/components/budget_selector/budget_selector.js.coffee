# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.BudgetSelector = React.createClass

  displayName: 'BudgetSelector'

  render: ->
    <div className="budget-selector">
      <div className="budget-slider">
        <div className="slider-body heatmap-area">
          <Views.Budgets.Estimate.Legend {...@props}/>
          <Views.Budgets.Estimate.Heatmap {...@props}/>
        </div>
      </div>
    </div>
