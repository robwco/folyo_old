# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.ProjectPickerOption = React.createClass

  displayName: 'ProjectPickerOption'

  options: ['no_coding', 'coding']

  optionLabels:
    no_coding: 'No Coding'
    coding:    'HTML/CSS coding'

  onOptionChange: (event) ->
    @props.setCurrentOption(event.target.value)

  render: ->

    createOption = (option) =>
      <div key={option} className="project-select-options">
        <label>
          <input name="project-select-options" type="radio"
            value={ option }
            checked={ option == @props.currentOption }
            onChange={ @onOptionChange }
          />
          <span>
            { @optionLabels[option] }
          </span>
        </label>
      </div>

    <div className="project-settings project-option">
      <div className="inner">
        <h3 className="project-settings-title">Options</h3>
        { @options.map(createOption) }
      </div>
    </div>