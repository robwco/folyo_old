# @cjsx React.DOM

Views.Budgets ||= {}
Views.Budgets.Estimate ||= {}

Views.Budgets.Estimate.Heatmap = React.createClass

  displayName: 'Heatmap'

  getDefaultProps: ->
    totalPoints: 100
    sizeMultiplier: 1.5

  getPricingPoints: ->
    points = if @props.currentCategory && @props.currentProjectType
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

    hash = []
    hash[point.price / @props.totalPoints] = point for point in points
    hash

  render: ->
    pricingPoints = @getPricingPoints()

    createPoint = (pointIndex) =>
      point = pricingPoints[pointIndex] || { count: 0, price: pointIndex * @props.totalPoints}
      pointSize = Math.round(@props.sizeMultiplier * point.count)
      pointStyle =
        left: "#{pointIndex}%"
        marginLeft: "-#{pointSize / 2}px";
        width: "#{pointSize}px"
        height: "#{pointSize}px"
      <div className="heatmap-point" key={"heatmap-point-#{point.price}"} style={pointStyle} />

    <div className="slider-heatmap">
      { [0..@props.totalPoints].map(createPoint) }
    </div>
