class DesignerSearchesController < ApplicationController

  before_filter :set_designer_search

  def accept
    designer = Designer.find(params[:designer_id])
    @search.accept!(designer)
    render_carrousel(@search, @search.next(designer))
  end

  def reject
    designer = Designer.find(params[:designer_id])
    @search.reject!(designer)
    render_carrousel(@search, @search.next(designer))
  end

  def next
    designer = Designer.find(params[:designer_id])
    render_carrousel(@search, @search.next(designer))
  end

  protected

  def set_designer_search
    @search = DesignerSearch.find(params[:id])
  end

  def render_carrousel(search, designer)
    render partial: 'carrousel', locals: { search: search, designer: designer }
  end

end