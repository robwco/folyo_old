# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.ProjectPickerCategory = React.createClass

  displayName: 'ProjectPickerCategory'

  categories: -> Object.keys(@props.stats)

  onCategoryChange: (event) ->
    @props.setCurrentCategory(event.target.value)

  render: ->

    createCategory = (category) =>
      <div key={category} className="project-select-category">
        <label>
          <input name="project-select-category" type="radio"
            value={ category }
            checked={ category == @props.currentCategory }
            onChange={ @onCategoryChange }
          />
          <span>
            { @props.stats[category].name }
          </span>
        </label>
      </div>

    <div className="project-settings project-category">
      <div className="inner">
        <h3 className="project-settings-title">Category</h3>
        { @categories().map(createCategory) }
      </div>
    </div>