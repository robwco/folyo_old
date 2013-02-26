module DesignerCarrouselHelper

  def carrousel_width(designer)
    "#{designer.resources.length * 100}%"
  end

  def carrousel_entry_width(designer)
    "#{100.0 / designer.resources.length}%"
  end

  def carrousel_entry_scroll(index)
    "#{-index * 100}%"
  end

end