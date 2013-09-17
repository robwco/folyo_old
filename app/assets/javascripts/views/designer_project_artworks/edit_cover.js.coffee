window.Views.DesignerProjectArtworks ||= {}

class Views.DesignerProjectArtworks.EditCoverView extends Views.ApplicationView

  $cropbox = undefined

  render: ->
    super()
    $cropbox = $('#cropbox')
    $cropbox.Jcrop(
      onChange: @update_crop
      onSelect: @update_crop,
      setSelect: [0, 0, 500, 500]
      aspectRatio: 3/4
    )

  update_crop: (coords) ->
    rx = 75 / coords.w
    ry = 100 / coords.h

    $('#preview').css(
      width: "#{Math.round(rx * $cropbox.attr('data-width'))}px"
      height: "#{Math.round(rx * $cropbox.attr('data-height'))}px"
      marginLeft: '-' + Math.round(rx * coords.x) + 'px'
      marginTop: '-' + Math.round(ry * coords.y) + 'px'
    )

    ratio = $cropbox.attr('data-ratio');
    $("#crop_x").val(Math.round(coords.x * ratio))
    $("#crop_y").val(Math.round(coords.y * ratio))
    $("#crop_w").val(Math.round(coords.w * ratio))
    $("#crop_h").val(Math.round(coords.h * ratio))

