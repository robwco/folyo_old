# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.ProjectPicker = React.createClass

  displayName: 'ProjectPicker'

  hasOptions: (category, projectType) -> @props.stats[category].project_types[projectType].coding_option

  gridCssClass: ->
    if @props.currentCategory
      if @props.currentProjectType && @hasOptions(@props.currentCategory, @props.currentProjectType)
          'three-columns'
      else
        'two-columns'
    else
      'one-column'

  render: ->
    <div className="budget-project #{@gridCssClass()}">
      <form>
        <Views.Budgets.Estimate.ProjectPickerCategory {...@props} />
        { <Views.Budgets.Estimate.ProjectPickerProjectType {...@props} /> if @props.currentCategory }
        { <Views.Budgets.Estimate.ProjectPickerOption {...@props} /> if @props.currentProjectType && @hasOptions(@props.currentCategory, @props.currentProjectType) }
      </form>
    </div>