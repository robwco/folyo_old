# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.Estimator = React.createClass

  displayName: 'Estimator'

  getInitialState: -> {}

  updateState: (properties) -> @setState(Object.assign(@state, properties))

  setCurrentCategory: (category) -> @updateState(currentCategory: category, currentProjectType: null, currentOption: null)

  setCurrentProjectType: (projectType) -> @updateState(currentProjectType: projectType, currentOption: null)

  setCurrentOption: (option) -> @updateState(currentOption: option)

  render: ->
    <div className="budget-estimator">
      <div className="budget-section">
        <h2 className="budget-section-title">1. Pick a Project</h2>
        <Views.Budgets.Estimate.ProjectPicker stats={@props.stats}
          currentCategory={@state.currentCategory} currentProjectType={@state.currentProjectType} currentOption={@state.currentOption}
          setCurrentCategory={@setCurrentCategory} setCurrentProjectType={@setCurrentProjectType} setCurrentOption={@setCurrentOption}
        />
      </div>
      <div className="budget-section">
        <h2 className="budget-section-title">2. Set a Budget</h2>
        <Views.Budgets.Estimate.BudgetSelector stats={@props.stats} maxBudget={20000}
          currentCategory={@state.currentCategory} currentProjectType={@state.currentProjectType} currentOption={@state.currentOption}
        />
      </div>
    </div>