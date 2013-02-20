class DesignerSearchController < ApplicationController

  before_filter :set_designer_search

  def accept
    designer = Designer.find(params[:designer_id])
    @designer_search.accept!(designer)
    render_next_designer_json(designer)
  end

  def reject
    designer = Designer.find(params[:designer_id])
    @designer_search.reject!(designer)
    render_next_designer_json(designer)
  end

  def next
    designer = Designer.find(params[:designer_id])
    render_next_designer_json(designer)
  end

  protected

  def set_designer_search
    @designer_search = DesignerSearch.find(params[:id])
  end

  def render_next_designer_json(designer)
    next_designer = @designer_search.next(designer)
    render json: {
      designer_id:  next_designer.id,
      full_name:    next_designer.full_name,
      dribbble_url: next_designer.dribbble_url,
      behance_url:  next_designer.behance_url
    }
  end

end