# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.ProjectPickerProjectType = React.createClass

  displayName: 'ProjectPickerCategory'

  projectTypes: -> Object.keys(@props.stats[@props.currentCategory].project_types)

  onProjectTypeChange: (event) ->
    @props.setCurrentProjectType(event.target.value)

  render: ->

    createProjectType = (projectType) =>
      <div key={projectType} className="project-select-type">
        <label>
          <input name="project-select-type" type="radio"
            value={ projectType }
            checked={ projectType == @props.currentProjectType }
            onChange={ @onProjectTypeChange }
          />
          <span>
            { @props.stats[@props.currentCategory].project_types[projectType].name }
          </span>
        </label>
      </div>

    <div className="project-settings project-type">
      <div className="inner">
        <h3 className="project-settings-title">Project</h3>
        { @projectTypes().map(createProjectType) }
      </div>
    </div>